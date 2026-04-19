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
export USER_PASS
nix shell nixpkgs#git nixpkgs#age nixpkgs#sops nixpkgs#mkpasswd --command bash <<EOF
set -e

echo "=== Running Disko ==="
nix run 'github:nix-community/disko#disko-install' -- --flake .#$HOST --disk main $DISK

echo "=== Secrets Bootstrap ==="
mkdir -p /mnt/persistent/var/lib/sops-nix/
chmod 755 /mnt/persistent/var/lib/sops-nix/

if [[ ! -f /mnt/persistent/var/lib/sops-nix/keys.txt ]]; then
    age-keygen -o /mnt/persistent/var/lib/sops-nix/keys.txt
fi
chmod 400 /mnt/persistent/var/lib/sops-nix/keys.txt

AGE_PUB_KEY=\$(age-keygen -y /mnt/persistent/var/lib/sops-nix/keys.txt)
echo "Generated age public key: \$AGE_PUB_KEY"

# Ensure basic placeholder secret files exist
if [[ ! -f secrets/secrets.yaml ]]; then
    USER_HASH=\$(mkpasswd -m yescrypt -s <<< "\$USER_PASS")
    cat > secrets/secrets.yaml <<YAML
git_credentials: |
    https://\$USERNAME:placeholder@github.com
user_password_\$USERNAME: \$USER_HASH
YAML
    sops --encrypt --in-place --age "\$AGE_PUB_KEY" secrets/secrets.yaml
fi

if [[ ! -f secrets/rclone.yaml ]]; then
    cat > secrets/rclone.yaml <<YAML
rclone_client_id: placeholder
rclone_token: placeholder
YAML
    sops --encrypt --in-place --age "\$AGE_PUB_KEY" secrets/rclone.yaml
fi

echo "=== Tracking Secrets ==="
git add -f secrets/

echo "=== Install NixOS ==="
nixos-install --flake .#$HOST --no-root-password

echo "=== Copying Config ==="
mkdir -p /mnt/persistent/home/$USERNAME/
cp -r "\$(pwd)" /mnt/persistent/home/$USERNAME/nixcfg
chown -R $USERNAME:users /mnt/persistent/home/$USERNAME/nixcfg || true

echo "Installation complete!"
EOF

read -p "Do you want to reboot now? [y/N] " REBOOT_CONFIRM
if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    sync
    reboot
fi
