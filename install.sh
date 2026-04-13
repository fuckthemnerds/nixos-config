#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then
	echo "ERROR: Please run as root."
	exit 1
fi

step() { echo -e "\n\033[1;34m[ STEP ]\033[0m $1"; }
ok()   { echo -e "\033[1;32m[ OK ]\033[0m $1"; }
err()  { echo -e "\033[1;31m[ ERR ]\033[0m $1"; exit 1; }

# --- Hardware Detection ---
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
SYSTEM_USER=${SYSTEM_USER}

step "Preparing partitions and mounting volumes..."
nix --extra-experimental-features "nix-command flakes" \
	--option extra-substituters https://install.determinate.systems \
	--option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= \
	run github:nix-community/disko -- \
	--mode destroy,format,mount \
	--argstr device "$DISK" \
	--yes-wipe-all-disks \
	"./hosts/$TARGET_HOST/disko.nix"

if ! mountpoint -q /mnt; then
	err "Failed to mount /mnt. Check disko output above."
fi

ok "File system prepared and mounted via Disko."

step "Bootstrapping SSH host keys..."
mkdir -p /mnt/persistent/etc/ssh

# Generate keys with restrictive umask to prevent world-readable window
(
	umask 077
	ssh-keygen -t ed25519 -N "" -C "" -f /mnt/persistent/etc/ssh/ssh_host_ed25519_key > /dev/null
	ssh-keygen -t rsa -b 4096 -N "" -C "" -f /mnt/persistent/etc/ssh/ssh_host_rsa_key > /dev/null
)
chmod 600 /mnt/persistent/etc/ssh/ssh_host_*_key
ok "Host keys generated in /mnt/persistent/etc/ssh."

step "Preparing system configuration..."
rm -rf /mnt/persistent/etc/nixos
mkdir -p /mnt/persistent/etc/nixos
cp -a "$(dirname "$0")"/. /mnt/persistent/etc/nixos/
mkdir -p /mnt/persistent/etc/nixos/secrets
mkdir -p /mnt/persistent/etc/nixos/local
cat > /mnt/persistent/etc/nixos/local/config.nix <<EOF
{
	# ── LOCAL CONFIGURATION OVERRIDES ──────────────────────────────────────────
	# This file is gitignored. Use it for personal identifiers (PII).

	userName     = "$SYSTEM_USER";
	userEmail    = "placeholder@example.com";
	stateVersion = "26.05";
	themeName    = "main";

	# --- Git Workflow ---
	gitPlatform  = "github";
	gitUser      = "placeholder";
	gitRepo      = "nixos-config";
}
EOF
ok "Local override generated for user: $SYSTEM_USER"

while true; do
	read -r -s -p "Set password for '$SYSTEM_USER': " USER_PASS; echo ""
	read -r -s -p "Confirm password: " USER_PASS2; echo ""
	[[ "$USER_PASS" == "$USER_PASS2" ]] && break
	echo "Passwords do not match. Please retry."
done

step "Hashing password..."
HASHED_PASSWORD=$(printf '%s' "$USER_PASS" | nix --extra-experimental-features "nix-command flakes" \
	--option extra-substituters https://install.determinate.systems \
	--option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= \
	shell nixpkgs#whois --command mkpasswd -m sha-512 -s)
unset USER_PASS USER_PASS2
ok "Password hashed."

# Export non-sensitive metadata for the subshell.
# HASHED_PASSWORD is exported instead of cleartext for better security.
export SYSTEM_USER TARGET_HOST HASHED_PASSWORD
nix --extra-experimental-features "nix-command flakes" \
	--option extra-substituters https://install.determinate.systems \
	--option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= \
	shell nixpkgs#ssh-to-age nixpkgs#sops nixpkgs#coreutils --command bash <<'EOF'
	set -e
	# Move to tmp to avoid finding placeholder .sops.yaml in repo root
	cd /tmp
	AGE_PUBKEY=$(ssh-to-age < /mnt/persistent/etc/ssh/ssh_host_ed25519_key.pub)

	# Generate .sops.yaml
	printf "keys:\n  - &host_%s %s\ncreation_rules:\n  - path_regex: secrets/.*\\.yaml$\n    key_groups:\n      - age:\n          - *host_%s\n" \
		"$TARGET_HOST" "$AGE_PUBKEY" "$TARGET_HOST" > /mnt/persistent/etc/nixos/.sops.yaml

	# Encrypt user password secret
	SOPS_AGE_KEY=$(ssh-to-age --private-key < /mnt/persistent/etc/ssh/ssh_host_ed25519_key) \
	sops --encrypt --age "$AGE_PUBKEY" --input-type yaml --output-type yaml \
			 <(printf "user_password_%s: \"%s\"\n" "$SYSTEM_USER" "$HASHED_PASSWORD") \
			 > /mnt/persistent/etc/nixos/secrets/secrets.yaml

	# Clear hash from memory after encryption
	unset HASHED_PASSWORD
EOF
ok "SOPS secrets successfully encrypted."

step "Configuring hardware-stub..."
nixos-generate-config --root /mnt --no-filesystems --dir /mnt/persistent/etc/nixos/hosts/"$TARGET_HOST" > /dev/null
mv /mnt/persistent/etc/nixos/hosts/"$TARGET_HOST"/hardware-configuration.nix /mnt/persistent/etc/nixos/hosts/"$TARGET_HOST"/hardware-stub.nix
rm -f /mnt/persistent/etc/nixos/hosts/"$TARGET_HOST"/configuration.nix

step "Finalizing Git repository..."
cd /mnt/persistent/etc/nixos || exit 1

# Ensure it's a git repo so flakes work
if [[ ! -d .git ]]; then
	git init > /dev/null
	git add .
fi

# Stage generated files (secrets and hardware-stub)
# Even if they are ignored, Nix flakes need them staged to 'see' them.
git add .sops.yaml secrets/secrets.yaml hosts/"$TARGET_HOST"/hardware-stub.nix 2>/dev/null
git add -f local/config.nix 2>/dev/null

read -r -p "Start nixos-install? (y/N): " RUN_INSTALL
if [[ "$RUN_INSTALL" =~ ^[Yy]$ ]]; then
	step "Running nixos-install (this may take a while)..."
	nixos-install --flake ".#$TARGET_HOST" --no-root-passwd \
		--option extra-substituters https://install.determinate.systems \
		--option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=
	ok "Installation complete."
	echo -e "\n\033[1;33m[ IMPORTANT ]\033[0m After rebooting:"
	echo "1. Edit /persistent/etc/nixos/local/config.nix to set your actual email and git details."
	echo "2. The system is currently on stateVersion 26.05. Update this only after a major NixOS release."
	echo "3. Run 'sudo sops /persistent/etc/nixos/secrets/secrets.yaml' if you need to adjust passwords."
else
	ok "Final installation phase skipped. Run 'nixos-install' manually when ready."
fi