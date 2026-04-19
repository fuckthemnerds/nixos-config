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

echo "┌─[ DEPLOYMENT MODE ]──────────────────────────────────────────────"
echo "│ [1] Local Disk (Live USB Target)"
echo "│ [2] Remote Device (SSH / nixos-anywhere)"
echo "└──────────────────────────────────────────────────────────────────"
while true; do
    read -p "[>] Select mode: " DEPLOY_MODE
    if [[ "$DEPLOY_MODE" == "1" || "$DEPLOY_MODE" == "2" ]]; then break; fi
done
echo "[+] Selected mode: $DEPLOY_MODE"
echo ""

if [[ "$DEPLOY_MODE" == "1" ]]; then
    echo "┌─[ AVAILABLE DISKS ]──────────────────────────────────────────────"
    lsblk -dpno NAME,SIZE,MODEL | grep -v 'loop' | nl -ba -nrz -w1 | \
        awk '{printf "│ [%s] %s %s %s\n", $1, $2, $3, $4}'
    echo "└──────────────────────────────────────────────────────────────────"
    read -p "[>] Select disk number: " DISK_NUM
    DISK=$(lsblk -dpno NAME | grep -v 'loop' | sed -n "${DISK_NUM}p")
    if [[ -z "$DISK" ]]; then exit 1; fi
    echo "[+] Selected disk: $DISK"
    echo ""
    echo "███████████████████████████████████████████████████████████████████"
    echo "█   WARNING: ALL DATA ON $DISK WILL BE IRRECOVERABLY DESTROYED    █"
    echo "███████████████████████████████████████████████████████████████████"
    read -p "[>] Type YES to continue: " CONFIRM_WIPE
    if [[ "$CONFIRM_WIPE" != "YES" ]]; then exit 1; fi

elif [[ "$DEPLOY_MODE" == "2" ]]; then
    echo "┌─[ REMOTE TARGET ]────────────────────────────────────────────────"
    read -p "│ [>] Enter IP address: " REMOTE_IP
    echo "└──────────────────────────────────────────────────────────────────"
    if [[ -z "$REMOTE_IP" ]]; then exit 1; fi
    echo "[+] Selected remote target: root@$REMOTE_IP"
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

export USERNAME HOST DISK DEPLOY_MODE REMOTE_IP FLAKE_REF USER_PASS

cat > /tmp/run-nixos-install.sh << 'EOF'
#!/usr/bin/env bash
set -e

_spin_pid=""

spinner() {
    local msg="$1"
    local frames=('[■□□□]' '[□■□□]' '[□□■□]' '[□□□■]')
    local i=0
    while true; do
        printf "\r%s %s" "${frames[$((i % ${#frames[@]}))]}" "$msg"
        sleep 0.1
        ((i++))
    done
}

spin_start() { spinner "$1" & _spin_pid=$!; disown; }

spin_stop() {
    if [[ -n "$_spin_pid" ]]; then
        kill "$_spin_pid" 2>/dev/null; wait "$_spin_pid" 2>/dev/null || true
        _spin_pid=""
        printf "\r\033[2K"
    fi
}

trap spin_stop EXIT

echo "==================================================================="
echo "                         SECRETS BOOTSTRAP                         "
echo "==================================================================="

umask 077
mkdir -p /tmp/sops-nix/

HOST_KEY_FILE="/tmp/sops-nix/keys.txt"
export SOPS_AGE_KEY_FILE="$HOST_KEY_FILE"
HOST_PUBKEY_FILE="secrets/age_keys/${HOST}.pub"

if [[ ! -f "$HOST_KEY_FILE" ]]; then
    spin_start "Generating age key for $HOST..."
    age-keygen -o "$HOST_KEY_FILE" 2>&1
    spin_stop
fi
chmod 400 "$HOST_KEY_FILE"

THIS_HOST_PUBKEY=$(age-keygen -y "$HOST_KEY_FILE")
echo "[+] Age public key for $HOST: $THIS_HOST_PUBKEY"

mkdir -p secrets/age_keys
echo "$THIS_HOST_PUBKEY" > "$HOST_PUBKEY_FILE"
git add "$HOST_PUBKEY_FILE"

ALL_PUBKEYS=()
for pk_file in secrets/age_keys/*.pub; do
    [[ -f "$pk_file" ]] && ALL_PUBKEYS+=("$(cat "$pk_file")")
done

AGE_RECIPIENTS_YAML=""
for pk in "${ALL_PUBKEYS[@]}"; do
    AGE_RECIPIENTS_YAML+="        - $pk"$'\n'
done

cat > .sops.yaml <<SOPS
creation_rules:
  - path_regex: secrets/secrets\.yaml$
    age:
$(printf '%s' "$AGE_RECIPIENTS_YAML")
  - path_regex: secrets/rclone\.yaml$
    age:
$(printf '%s' "$AGE_RECIPIENTS_YAML")
SOPS
git add .sops.yaml
echo "[+] .sops.yaml updated with ${#ALL_PUBKEYS[@]} recipient(s)"

if [[ ! -f secrets/secrets.yaml ]]; then
    spin_start "Hashing password..."
    USER_HASH=$(mkpasswd -m yescrypt -s <<< "$USER_PASS")
    unset USER_PASS
    spin_stop

    spin_start "Encrypting secrets.yaml..."
    cat <<YAML | sops --encrypt \
        --filename-override secrets/secrets.yaml \
        --input-type yaml --output-type yaml /dev/stdin > secrets/secrets.yaml
git_credentials: |
  https://$USERNAME:placeholder@github.com
user_password_$USERNAME: $USER_HASH
YAML
    unset USER_HASH
    git add secrets/secrets.yaml
    spin_stop
else
    spin_start "Updating recipients in secrets.yaml..."
    sops updatekeys --yes secrets/secrets.yaml
    git add secrets/secrets.yaml
    spin_stop
fi

if [[ ! -f secrets/rclone.yaml ]]; then
    spin_start "Encrypting rclone.yaml..."
    cat <<YAML | sops --encrypt \
        --filename-override secrets/rclone.yaml \
        --input-type yaml --output-type yaml /dev/stdin > secrets/rclone.yaml
rclone_client_id: placeholder
rclone_token: placeholder
YAML
    git add secrets/rclone.yaml
    spin_stop
else
    spin_start "Updating recipients in rclone.yaml..."
    sops updatekeys --yes secrets/rclone.yaml
    git add secrets/rclone.yaml
    spin_stop
fi

git add secrets/

if [[ "$DEPLOY_MODE" == "1" ]]; then
    echo ""
    echo "==================================================================="
    echo "                           LOCAL DEPLOY                            "
    echo "==================================================================="
    stdbuf -oL nix run -L 'github:nix-community/disko' -- \
        --mode destroy,format,mount \
        --flake "${FLAKE_REF}#$HOST" --disk main "$DISK" 2>&1 | stdbuf -oL tee /tmp/disko.log

    mkdir -p /mnt/persistent/var/lib/sops-nix/
    chmod 755 /mnt/persistent/var/lib/sops-nix/
    cp "$HOST_KEY_FILE" /mnt/persistent/var/lib/sops-nix/keys.txt
    chmod 400 /mnt/persistent/var/lib/sops-nix/keys.txt

    echo ""
    echo "==================================================================="
    echo "                         INSTALLING NIXOS                          "
    echo "==================================================================="
    stdbuf -oL nixos-install --flake "${FLAKE_REF}#$HOST" --no-root-password 2>&1 | stdbuf -oL tee /tmp/nixos-install.log

    mkdir -p "/mnt/persistent/home/$USERNAME/"
    cp -r "$(pwd)" "/mnt/persistent/home/$USERNAME/nixcfg"
    if chroot /mnt id "$USERNAME" >/dev/null 2>&1; then
        chroot /mnt chown -R "$USERNAME:users" "/persistent/home/$USERNAME/nixcfg" || true
    fi

elif [[ "$DEPLOY_MODE" == "2" ]]; then
    echo ""
    echo "==================================================================="
    echo "                           REMOTE DEPLOY                           "
    echo "==================================================================="
    mkdir -p /tmp/extra-files/var/lib/sops-nix
    cp "$HOST_KEY_FILE" /tmp/extra-files/var/lib/sops-nix/keys.txt
    chmod -R 700 /tmp/extra-files
    chmod 400 /tmp/extra-files/var/lib/sops-nix/keys.txt

    stdbuf -oL nix run github:nix-community/nixos-anywhere -- \
        --flake "${FLAKE_REF}#$HOST" \
        --extra-files /tmp/extra-files \
        "root@$REMOTE_IP" 2>&1 | stdbuf -oL tee /tmp/nixos-anywhere.log
fi

echo ""
echo "==================================================================="
echo "                       INSTALLATION COMPLETE                       "
echo "==================================================================="
EOF

chmod +x /tmp/run-nixos-install.sh
nix shell nixpkgs#git nixpkgs#age nixpkgs#sops nixpkgs#mkpasswd \
    --command /tmp/run-nixos-install.sh

if [[ "$DEPLOY_MODE" == "1" ]]; then
    echo "┌─[ SYSTEM REBOOT ]────────────────────────────────────────────────"
    read -p "│ [>] Reboot now? [y/N] " REBOOT_CONFIRM
    echo "└──────────────────────────────────────────────────────────────────"
    if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
        sync
        reboot
    fi
fi