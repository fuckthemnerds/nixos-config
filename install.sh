#!/usr/bin/env bash
set -e
[ ! -d .git ] && git init


export NIX_CONFIG="experimental-features = nix-command flakes"
FLAKE_REF="${FLAKE_REF:-git+file:.}"

echo "==================================================================="
echo "                      NIXOS PRE-FLIGHT SETUP                       "
echo "==================================================================="
echo ""

HOSTS_STR=$(nix eval --raw --impure --expr \
  'builtins.concatStringsSep " " (builtins.attrNames (builtins.getFlake (toString ./.)).nixosConfigurations)' \
  2>/dev/null || echo "aorus surface")
read -r -a HOSTS <<< "$HOSTS_STR"

echo "┌─[ AVAILABLE HOSTS ]──────────────────────────────────────────────"
for i in "${!HOSTS[@]}"; do
    printf "│ [%d] %s\n" "$((i+1))" "${HOSTS[$i]}"
done
echo "└──────────────────────────────────────────────────────────────────"
while true; do
    read -p "[>] Select host number: " HOST_NUM
    if [[ "$HOST_NUM" -gt 0 && "$HOST_NUM" -le "${#HOSTS[@]}" ]]; then
        HOST="${HOSTS[$((HOST_NUM-1))]}"
        break
    fi
done
echo "[+] Selected host: $HOST"
echo ""

echo "┌─[ AVAILABLE DISKS ]──────────────────────────────────────────────"
lsblk -dpno NAME,SIZE,MODEL | grep -v 'loop' | nl -ba -nrz -w1 | \
    awk '{printf "│ [%s] %s %s %s\n", $1, $2, $3, $4}'
echo "└──────────────────────────────────────────────────────────────────"
read -p "[>] Select disk number: " DISK_NUM
DISK=$(lsblk -dpno NAME | grep -v 'loop' | sed -n "${DISK_NUM}p")
if [[ -z "$DISK" ]]; then exit 1; fi
echo "[+] Selected disk: $DISK"
echo ""
echo "┌──────────────────────────────────────────────────────────────────"
echo "   WARNING: ALL DATA ON $DISK WILL BE IRRECOVERABLY DESTROYED      "
echo "└──────────────────────────────────────────────────────────────────"
read -p "[>] Type YES to continue: " CONFIRM_WIPE
if [[ "$CONFIRM_WIPE" != "YES" ]]; then exit 1; fi
echo ""

echo "┌─[ SOPS MASTER KEY ]──────────────────────────────────────────────"
read -p "│ [>] Generate a new SOPS master key for decryption? [y/N]: " GEN_MASTER
echo "└──────────────────────────────────────────────────────────────────"
if [[ "$GEN_MASTER" =~ ^[Yy]$ ]]; then
    export GEN_MASTER="yes"
else
    export GEN_MASTER="no"
fi
echo ""

echo "┌─[ USER CREDENTIALS ]─────────────────────────────────────────────"
read -p "│ [>] Username: " USERNAME
USERNAME=${USERNAME:-mad}
read -p "│ [>] Email: " USEREMAIL
while true; do
    read -sp "│ [>] Password for $USERNAME: " USER_PASS
    echo ""
    if [[ -z "$USER_PASS" ]]; then continue; fi
    read -sp "│ [>] Verify password: " USER_PASS_VERIFY
    echo ""
    if [[ "$USER_PASS" == "$USER_PASS_VERIFY" ]]; then break; fi
    echo "│ [!] Passwords do not match."
done
echo "└──────────────────────────────────────────────────────────────────"
echo ""

umask 077
mkdir -p secrets
cat > secrets/usercreds.nix <<EOF
{
  userName = "$USERNAME";
  userEmail = "$USEREMAIL";
}
EOF
git add secrets/usercreds.nix

export USERNAME HOST DISK FLAKE_REF USER_PASS GEN_MASTER

cat > /tmp/run-nixos-install.sh << 'EOF'
#!/usr/bin/env bash
set -e

echo "==================================================================="
echo "                         SECRETS BOOTSTRAP                         "
echo "==================================================================="

umask 077
mkdir -p /tmp/sops-nix/
mkdir -p secrets/

HOST_KEY_FILE="/tmp/sops-nix/keys.txt"
export SOPS_AGE_KEY_FILE="$HOST_KEY_FILE"
HOST_PUBKEY_FILE="secrets/${HOST}.pub"

# 0. Handle Master Age Key
if [[ "$GEN_MASTER" == "yes" ]]; then
    MASTER_KEY_FILE="$HOME/.config/sops/age/keys.txt"
    mkdir -p "$(dirname "$MASTER_KEY_FILE")"
    if [[ ! -f "$MASTER_KEY_FILE" ]]; then
        echo "[*] Generating master age key..."
        age-keygen -o "$MASTER_KEY_FILE" 2>/dev/null
        chmod 400 "$MASTER_KEY_FILE"
    else
        echo "[!] Master key already exists at $MASTER_KEY_FILE"
    fi
    MASTER_PUBKEY=$(age-keygen -y "$MASTER_KEY_FILE")
    echo "[+] Master Public Key: $MASTER_PUBKEY"
    echo "$MASTER_PUBKEY" > secrets/master.pub
    git add secrets/master.pub
fi

# 1. Handle Host Age Key
if [[ ! -f "$HOST_KEY_FILE" ]]; then
    if [[ -f "$HOST_PUBKEY_FILE" ]]; then
        echo "[!] Warning: Public key for $HOST already exists in repo, but private key is missing."
        echo "[!] Generating a new key for this deployment..."
    fi
    echo "[*] Generating age key for $HOST..."
    age-keygen -o "$HOST_KEY_FILE" 2>/dev/null
fi
chmod 400 "$HOST_KEY_FILE"

THIS_HOST_PUBKEY=$(age-keygen -y "$HOST_KEY_FILE")
echo "[+] Host Public Key ($HOST): $THIS_HOST_PUBKEY"
echo "$THIS_HOST_PUBKEY" > "$HOST_PUBKEY_FILE"

# 2. Gather All Recipients (including Master Key if it exists)
ALL_PUBKEYS=()
for pk_file in secrets/*.pub; do
    if [[ -f "$pk_file" ]]; then
        PUBKEY=$(cat "$pk_file")
        ALL_PUBKEYS+=("$PUBKEY")
        echo "[+] Adding recipient: $(basename "$pk_file" .pub) ($PUBKEY)"
    fi
done

# 3. Generate .sops.yaml
AGE_RECIPIENTS_YAML=""
for pk in "${ALL_PUBKEYS[@]}"; do
    AGE_RECIPIENTS_YAML+="          - $pk"$'\n'
done

cat > .sops.yaml <<SOPS
creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
$(printf '%s' "$AGE_RECIPIENTS_YAML")
SOPS
git add .sops.yaml
echo "[+] .sops.yaml updated with ${#ALL_PUBKEYS[@]} recipient(s)"

if [[ ! -f secrets/secrets.yaml ]] || ! grep -q "sops:" secrets/secrets.yaml 2>/dev/null; then
    echo "[*] Hashing password..."
    USER_HASH=$(mkpasswd -m yescrypt -s <<< "$USER_PASS")
    unset USER_PASS

    echo "[*] Encrypting secrets.yaml..."
    cat <<YAML | sops --encrypt \
        --filename-override secrets/secrets.yaml \
        --input-type yaml --output-type yaml /dev/stdin > secrets/secrets.yaml
git_credentials: |
  https://$USERNAME:placeholder@github.com
user_password_$USERNAME: $USER_HASH
YAML
    unset USER_HASH
    git add secrets/secrets.yaml
else
    echo "[*] Updating recipients in secrets.yaml..."
    sops updatekeys --yes secrets/secrets.yaml
    git add secrets/secrets.yaml
fi

if [[ ! -f secrets/rclone.yaml ]] || ! grep -q "sops:" secrets/rclone.yaml 2>/dev/null; then
    echo "[*] Encrypting rclone.yaml..."
    cat <<YAML | sops --encrypt \
        --filename-override secrets/rclone.yaml \
        --input-type yaml --output-type yaml /dev/stdin > secrets/rclone.yaml
rclone_client_id: placeholder
rclone_token: placeholder
YAML
    git add secrets/rclone.yaml
else
    echo "[*] Updating recipients in rclone.yaml..."
    sops updatekeys --yes secrets/rclone.yaml
    git add secrets/rclone.yaml
fi

git add secrets/

echo ""
echo "==================================================================="
echo "                           LOCAL DEPLOY                            "
echo "==================================================================="
nix run -L 'github:nix-community/disko' -- \
    --mode destroy,format,mount \
    --flake "${FLAKE_REF}#$HOST" --disk main "$DISK"

mkdir -p /mnt/persistent/var/lib/sops-nix/
chmod 755 /mnt/persistent/var/lib/sops-nix/
cp "$HOST_KEY_FILE" /mnt/persistent/var/lib/sops-nix/keys.txt
chmod 400 /mnt/persistent/var/lib/sops-nix/keys.txt

echo ""
echo "==================================================================="
echo "                     GENERATING HARDWARE CONFIG                    "
echo "==================================================================="
nixos-generate-config --no-filesystems --root /mnt --dir /tmp/nixos-hw
mkdir -p "hosts/$HOST"
cp /tmp/nixos-hw/hardware-configuration.nix "hosts/$HOST/hardware.nix"

echo ""
echo "==================================================================="
echo "                         INSTALLING NIXOS                          "
echo "==================================================================="
nixos-install --flake "${FLAKE_REF}#$HOST" --no-root-password

mkdir -p "/mnt/persistent/home/$USERNAME/"
cp -r "$(pwd)" "/mnt/persistent/home/$USERNAME/nixcfg"
if chroot /mnt id "$USERNAME" >/dev/null 2>&1; then
    chroot /mnt chown -R "$USERNAME:users" "/persistent/home/$USERNAME/nixcfg" || true
fi

echo ""
echo "==================================================================="
echo "                       INSTALLATION COMPLETE                       "
echo "==================================================================="
EOF

chmod +x /tmp/run-nixos-install.sh
nix shell nixpkgs#git nixpkgs#age nixpkgs#sops nixpkgs#mkpasswd \
    --command /tmp/run-nixos-install.sh

echo "┌─[ SYSTEM REBOOT ]────────────────────────────────────────────────"
read -p "│ [>] Reboot now? [y/N] " REBOOT_CONFIRM
echo "└──────────────────────────────────────────────────────────────────"
if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    sync
    reboot
fi