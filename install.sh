#!/usr/bin/env bash
set -e

# Installer environment
export NIX_CONFIG="experimental-features = nix-command flakes"

echo "=== NixOS Interactive Pre-flight Setup ==="

# 1. Host selection
HOSTS=("aorus" "surface")
echo "Available hosts:"
select HOST in "${HOSTS[@]}"; do
    if [[ -n "$HOST" ]]; then
        break
    else
        echo "Invalid selection."
    fi
done
echo "Selected host: $HOST"

# 2. User defaults
read -p "Enter your username [mad]: " USERNAME
USERNAME=${USERNAME:-mad}
read -p "Enter your email: " USEREMAIL
while true; do
    read -sp "Enter password for $USERNAME: " USER_PASS
    echo
    if [[ -z "$USER_PASS" ]]; then
        echo "Password cannot be empty."
        continue
    fi
    read -sp "Verify password for $USERNAME: " USER_PASS_VERIFY
    echo
    if [[ "$USER_PASS" == "$USER_PASS_VERIFY" ]]; then
        break
    else
        echo "Passwords do not match. Try again."
    fi
done
echo
mkdir -p secrets
cat > secrets/usercreds.nix <<EOF
{
  userName = "$USERNAME";
  userEmail = "$USEREMAIL";
}
EOF

# 3. Disk selection
echo "Available disks:"
lsblk -dpno NAME,SIZE,MODEL | grep -v 'loop' | nl
read -p "Select a disk number for installation: " DISK_NUM
DISK=$(lsblk -dpno NAME | grep -v 'loop' | sed -n "${DISK_NUM}p")

if [[ -z "$DISK" ]]; then
    echo "Invalid disk selection."
    exit 1
fi
echo "Selected disk: $DISK"

echo -e "\nWARNING: ALL DATA ON $DISK WILL BE IRRECOVERABLY DESTROYED."
read -p "Type YES to continue: " CONFIRM_WIPE
if [[ "$CONFIRM_WIPE" != "YES" ]]; then
    echo "Aborting."
    exit 1
fi

# Run everything from within a nix shell with required tools
export USER_PASS USERNAME HOST DISK

cat > /tmp/run-nixos-install.sh << 'EOF'
#!/usr/bin/env bash
set -e

# --- spinner ---
_spin_pid=""
spinner() {
    local msg="$1"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while true; do
        printf "\r  %s %s " "${frames[$((i % ${#frames[@]}))]}" "$msg"
        sleep 0.1
        ((i++))
    done
}
spin_start() { spinner "$1" & _spin_pid=$!; disown; }
spin_stop()  {
    if [[ -n "$_spin_pid" ]]; then
        kill "$_spin_pid" 2>/dev/null; wait "$_spin_pid" 2>/dev/null || true
        _spin_pid=""
        printf "\r\033[2K"
    fi
}
trap spin_stop EXIT

echo "=== Secrets Bootstrap ==="
mkdir -p /tmp/sops-nix/

if [[ ! -f /tmp/sops-nix/keys.txt ]]; then
    spin_start "Generating age key..."
    age-keygen -o /tmp/sops-nix/keys.txt 2>&1
    spin_stop
fi
chmod 400 /tmp/sops-nix/keys.txt

AGE_PUB_KEY=$(age-keygen -y /tmp/sops-nix/keys.txt)
echo "Generated age public key: $AGE_PUB_KEY"

sed -i "s/age1placeholder_replace_with_real_host_key_[a-zA-Z0-9_-]*/$AGE_PUB_KEY/g" .sops.yaml

if [[ ! -f secrets/secrets.yaml ]]; then
    spin_start "Hashing password..."
    USER_HASH=$(mkpasswd -m yescrypt -s <<< "$USER_PASS")
    spin_stop
    cat > secrets/secrets.yaml <<YAML
git_credentials: |
    https://$USERNAME:placeholder@github.com
user_password_$USERNAME: $USER_HASH
YAML
    spin_start "Encrypting secrets.yaml..."
    sops --encrypt --in-place secrets/secrets.yaml
    spin_stop
fi

if [[ ! -f secrets/rclone.yaml ]]; then
    cat > secrets/rclone.yaml <<YAML
rclone_client_id: placeholder
rclone_token: placeholder
YAML
    spin_start "Encrypting rclone.yaml..."
    sops --encrypt --in-place secrets/rclone.yaml
    spin_stop
fi

echo "=== Tracking Secrets ==="
git add -f secrets/

echo ""
echo "=== Running Disko (disk partitioning + format) ==="
echo "    Output streamed live below:"
echo "------------------------------------------------------------"
# -L = verbose nix logs; output piped through stdbuf to prevent buffering
stdbuf -oL nix run -L 'github:nix-community/disko#disko-install' -- \
    --flake .#$HOST --disk main $DISK 2>&1 | stdbuf -oL tee /tmp/disko.log
echo "------------------------------------------------------------"
echo "Disko done."

echo ""
echo "=== Deploying Secrets to Target ==="
mkdir -p /mnt/persistent/var/lib/sops-nix/
chmod 755 /mnt/persistent/var/lib/sops-nix/
cp /tmp/sops-nix/keys.txt /mnt/persistent/var/lib/sops-nix/keys.txt
chmod 400 /mnt/persistent/var/lib/sops-nix/keys.txt

echo ""
echo "=== Installing NixOS (this takes a while) ==="
echo "    Output streamed live below:"
echo "------------------------------------------------------------"
stdbuf -oL nixos-install --flake .#$HOST --no-root-password 2>&1 | stdbuf -oL tee /tmp/nixos-install.log
echo "------------------------------------------------------------"
echo "NixOS install done."

echo ""
echo "=== Copying Config ==="
mkdir -p /mnt/persistent/home/$USERNAME/
cp -r "$(pwd)" /mnt/persistent/home/$USERNAME/nixcfg
chown -R $USERNAME:users /mnt/persistent/home/$USERNAME/nixcfg || true

echo ""
echo "Installation complete!"
EOF

chmod +x /tmp/run-nixos-install.sh
nix shell nixpkgs#git nixpkgs#age nixpkgs#sops nixpkgs#mkpasswd --command /tmp/run-nixos-install.sh

read -p "Do you want to reboot now? [y/N] " REBOOT_CONFIRM
if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    sync
    reboot
fi
