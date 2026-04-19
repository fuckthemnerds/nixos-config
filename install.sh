#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ "$SCRIPT_DIR" == /nix/store/* ]]; then
    SCRIPT_DIR="$(pwd)"
fi
STATE_VERSION="26.05"

NIX_OPTS=(
	--extra-experimental-features "nix-command flakes"
	--option extra-substituters https://install.determinate.systems
	--option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=
)

if [[ $EUID -ne 0 ]]; then
	echo "ERROR: Please run as root."
	exit 1
fi

step() { echo -e "\n\033[1;34m[ STEP ]\033[0m $1"; }
ok()   { echo -e "\033[1;32m[ OK ]\033[0m $1"; }
err()  { echo -e "\033[1;31m[ ERR ]\033[0m $1"; exit 1; }

DEFAULT_DISK=""
if [[ -b "/dev/nvme0n1" ]]; then
	DEFAULT_DISK="/dev/nvme0n1"
fi

DEFAULT_HOST=""
if grep -qi "surface" /sys/class/dmi/id/product_name 2>/dev/null || grep -qi "surface" /sys/class/dmi/id/chassis_asset_tag 2>/dev/null; then
	DEFAULT_HOST="surface"
elif grep -qi "AORUS\|Gigabyte" /sys/class/dmi/id/board_vendor 2>/dev/null || grep -qi "AORUS\|Gigabyte" /sys/class/dmi/id/bios_vendor 2>/dev/null; then
	DEFAULT_HOST="aorus"
fi

lsblk -d -n -o NAME,SIZE,MODEL | awk '{print "/dev/" $1 " - " $2 " - " $3}'
echo ""
read -r -p "Target disk${DEFAULT_DISK:+ [$DEFAULT_DISK]}: " DISK
DISK=${DISK:-$DEFAULT_DISK}

[[ -b "$DISK" ]] || err "Disk $DISK not found."

echo -e "\n\033[1;31mWARNING: All data on $DISK will be permanently destroyed.\033[0m"
read -r -p "Type 'YES' to confirm: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || err "Installation aborted."

read -r -p "Target host (aorus/surface)${DEFAULT_HOST:+ [$DEFAULT_HOST]}: " TARGET_HOST
TARGET_HOST=${TARGET_HOST:-$DEFAULT_HOST}
[[ "$TARGET_HOST" =~ ^(aorus|surface)$ ]] || err "Invalid host choice."

read -r -p "System username: " SYSTEM_USER
if [[ ! "$SYSTEM_USER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
	err "Invalid username '$SYSTEM_USER'. Must match POSIX pattern: ^[a-z_][a-z0-9_-]*$"
fi

step "Preparing partitions and mounting volumes..."
nix "${NIX_OPTS[@]}" \
	run github:nix-community/disko -- \
	--mode destroy,format,mount \
	--argstr device "$DISK" \
	--yes-wipe-all-disks \
	"./hosts/$TARGET_HOST/disko.nix"

if ! mountpoint -q /mnt; then
	err "Failed to mount /mnt. Check disko output above."
fi
for mp in /mnt/boot /mnt/persistent; do
	if ! mountpoint -q "$mp" 2>/dev/null; then
		err "Expected mountpoint $mp is not mounted. Disko may have partially failed."
	fi
done

ok "File system prepared and mounted via Disko."

step "Bootstrapping SSH host keys..."
mkdir -p /mnt/persistent/etc/ssh

(
	umask 077
	ssh-keygen -t ed25519 -N "" -C "" -f /mnt/persistent/etc/ssh/ssh_host_ed25519_key > /dev/null
	ssh-keygen -t rsa -b 4096 -N "" -C "" -f /mnt/persistent/etc/ssh/ssh_host_rsa_key > /dev/null
)
ok "Host keys generated in /mnt/persistent/etc/ssh."

step "Preparing system configuration..."
mkdir -p "$SCRIPT_DIR/local" "$SCRIPT_DIR/secrets"

# Only non-secret logic stays in the local config now
cat > "$SCRIPT_DIR/local/config.nix" <<EOF
{
	userName     = "$SYSTEM_USER";
	stateVersion = "$STATE_VERSION";
	themeName    = "main";
}
EOF
ok "Local override generated for user: $SYSTEM_USER"

SECRETS_FILE="$SCRIPT_DIR/secrets/secrets.yaml"
SOPS_CONFIG="$SCRIPT_DIR/.sops.yaml"

if [[ ! -f "$SECRETS_FILE" ]]; then
	step "FIRST DEVICE SETUP: Generating Admin Key and Secrets..."
	
	ADMIN_KEY_FILE="/tmp/admin_key.txt"
	nix "${NIX_OPTS[@]}" shell nixpkgs#age --command age-keygen -o "$ADMIN_KEY_FILE" > /dev/null 2>&1
	ADMIN_PUBKEY=$(nix "${NIX_OPTS[@]}" shell nixpkgs#age --command age-keygen -y "$ADMIN_KEY_FILE")
	
	echo -e "Your master public key is: \033[1;36m$ADMIN_PUBKEY\033[0m"

	while true; do
		read -r -s -p "Set password for '$SYSTEM_USER': " USER_PASS; echo ""
		read -r -s -p "Confirm password: " USER_PASS2; echo ""
		[[ "$USER_PASS" == "$USER_PASS2" ]] && break
		echo "Passwords do not match. Please retry."
	done

	step "Hashing password..."
	HASHED_PASSWORD=$(printf '%s' "$USER_PASS" | nix "${NIX_OPTS[@]}" \
		shell nixpkgs#whois --command mkpasswd -m sha-512 -s)
	unset USER_PASS USER_PASS2
	ok "Password hashed."
	
	read -r -p "Enter your Git display name [fuckthemnerds]: " GIT_USER
	GIT_USER=${GIT_USER:-fuckthemnerds}
	read -r -p "Enter your Git email [205473740+fuckthemnerds@users.noreply.github.com]: " GIT_EMAIL
	GIT_EMAIL=${GIT_EMAIL:-205473740+fuckthemnerds@users.noreply.github.com}
	
	export SYSTEM_USER TARGET_HOST HASHED_PASSWORD ADMIN_PUBKEY GIT_USER GIT_EMAIL SCRIPT_DIR
	nix "${NIX_OPTS[@]}" shell nixpkgs#ssh-to-age nixpkgs#sops nixpkgs#coreutils --command bash <<'EOF'
		set -e
		AGE_PUBKEY=$(ssh-to-age < /mnt/persistent/etc/ssh/ssh_host_ed25519_key.pub)
		
		# Properly format the YAML alias list and use a robust regex for Windows/Linux
		printf "keys:\n  - &admin %s\n  - &host_%s %s\n\ncreation_rules:\n  - path_regex: secrets[/\\\\\\\\].*\\\\.yaml$\n    key_groups:\n      - age:\n          - *admin\n          - *host_%s\n" \
			"$ADMIN_PUBKEY" "$TARGET_HOST" "$AGE_PUBKEY" "$TARGET_HOST" > "$SCRIPT_DIR/.sops.yaml"

		sops --encrypt --age "$ADMIN_PUBKEY,$AGE_PUBKEY" --input-type yaml --output-type yaml \
			<(printf "user_password_%s: \"%s\"\ngit_user: \"%s\"\ngit_email: \"%s\"\nrclone.conf: |\n  [gdrive]\n  type = drive\n  client_id = PLACEHOLDER\n  token = PLACEHOLDER\n" "$SYSTEM_USER" "$HASHED_PASSWORD" "$GIT_USER" "$GIT_EMAIL") \
			> "$SCRIPT_DIR/secrets/secrets.yaml"
EOF
	ok "SOPS secrets successfully created and encrypted."

else
	step "SECONDARY DEVICE SETUP: Existing secrets found."
	export TARGET_HOST
	nix "${NIX_OPTS[@]}" shell nixpkgs#ssh-to-age nixpkgs#coreutils --command bash <<'EOF'
		set -e
		AGE_PUBKEY=$(ssh-to-age < /mnt/persistent/etc/ssh/ssh_host_ed25519_key.pub)
		echo -e "\n\033[1;33m[ IMPORTANT: NEW HOST SECRETS ]\033[0m"
		echo "This host ($TARGET_HOST) needs access to your existing secrets."
		echo -e "Your new Host Age pubkey is: \033[1;36m$AGE_PUBKEY\033[0m\n"
		echo "Before continuing the installation, do the following on your FIRST machine:"
		echo "1. Add this pubkey to .sops.yaml under a new alias (e.g. &host_$TARGET_HOST)"
		echo "2. Add the alias to the key_groups list."
		echo "3. Run: sops updatekeys secrets/secrets.yaml"
		echo "4. Commit and push the changes."
		echo "5. Run 'git pull' on THIS machine to download the updated secrets."
EOF
	
	# Pause the script so the user can actually do the git pull before installing
	read -r -p "Press Enter when you have pulled the updated secrets.yaml..."
fi
step "Deploying configuration to target..."
if [[ -d /mnt/persistent/etc/nixos ]]; then
	echo "Existing config found — backing up to /mnt/persistent/etc/nixos.bak"
	rm -rf /mnt/persistent/etc/nixos.bak
	cp -a /mnt/persistent/etc/nixos /mnt/persistent/etc/nixos.bak
fi
rm -rf /mnt/persistent/etc/nixos
mkdir -p /mnt/persistent/etc/nixos
cp -a "$SCRIPT_DIR"/. /mnt/persistent/etc/nixos/

step "Configuring hardware-stub..."
nixos-generate-config --root /mnt --no-filesystems --dir /mnt/persistent/etc/nixos/hosts/"$TARGET_HOST" > /dev/null
mv /mnt/persistent/etc/nixos/hosts/"$TARGET_HOST"/hardware-configuration.nix /mnt/persistent/etc/nixos/hosts/"$TARGET_HOST"/hardware-stub.nix
rm -f /mnt/persistent/etc/nixos/hosts/"$TARGET_HOST"/configuration.nix

step "Finalizing Git repository..."
cd /mnt/persistent/etc/nixos || exit 1

if [[ ! -d .git ]]; then
	git init > /dev/null
fi

git add .sops.yaml secrets/secrets.yaml secrets/rclone.yaml hosts/"$TARGET_HOST"/hardware-stub.nix 2>/dev/null
git add -f local/config.nix 2>/dev/null

read -r -p "Start nixos-install? (y/N): " RUN_INSTALL
if [[ "$RUN_INSTALL" =~ ^[Yy]$ ]]; then
	step "Running nixos-install (this may take a while)..."
	nixos-install --flake ".#$TARGET_HOST" --no-root-passwd \
		"${NIX_OPTS[@]:2}"
	ok "Installation complete."

	echo -e "\n\033[1;33m[ IMPORTANT ]\033[0m Before rebooting:"
	if [[ -f /tmp/admin_key.txt ]]; then
		step "Securing Admin Key to Persistent Storage..."
		mkdir -p "/mnt/persistent/home/$SYSTEM_USER/.config/sops/age"
		cp /tmp/admin_key.txt "/mnt/persistent/home/$SYSTEM_USER/.config/sops/age/keys.txt"
		# Assuming the first created user has UID 1000 and GID 100
		chown -R 1000:100 "/mnt/persistent/home/$SYSTEM_USER/.config/sops"
		chmod 600 "/mnt/persistent/home/$SYSTEM_USER/.config/sops/age/keys.txt"
		ok "Admin key secured in user home directory."
	else
		echo "Secondary device installed. Your Admin Key remains safely on your primary device."
	fi
else
	ok "Final installation phase skipped. Run 'nixos-install' manually when ready."
fi