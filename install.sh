#!/usr/bin/env bash
set -e


RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

CHECK="✔"
CROSS="✘"

WIDTH=70

box_line() {
    local text="│ $1"
    local border_color=$2
    local text_len=${#text}
    local padding=$((WIDTH - text_len - 1))
    [[ $padding -lt 0 ]] && padding=0
    
    echo -e "${border_color}${text}$(printf ' %.0s' $(seq 1 $padding))│${NC}"
}

box_header() {
    local msg=$1
    local color=$2
    local prefix="┌─[ $msg ]"
    local prefix_len=${#prefix}
    local dashes=$((WIDTH - prefix_len - 1))
    [[ $dashes -lt 0 ]] && dashes=0
    echo -e "${color}${prefix}$(printf '─%.0s' $(seq 1 $dashes))┐${NC}"
}

box_footer() {
    local color=$1
    echo -e "${color}└$(printf '─%.0s' $(seq 1 $((WIDTH - 2))))┘${NC}"
}

header() {
    local title=$1
    echo -e "\n${BLUE}┌$(printf '─%.0s' $(seq 1 $((WIDTH - 2))))┐${NC}"
    local padding=$(( (WIDTH - ${#title} - 2) / 2 ))
    local pad_right=$((WIDTH - padding - ${#title} - 2))
    echo -e "${BLUE}│${NC}${BOLD}$(printf '%*s' $padding "")$title$(printf '%*s' $pad_right "")${NC}${BLUE}│${NC}"
    echo -e "${BLUE}└$(printf '─%.0s' $(seq 1 $((WIDTH - 2))))┘${NC}\n"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local msg=$2
    
    tput civis 2>/dev/null || true
    while ps -p $pid > /dev/null; do
        for i in $(seq 0 9); do
            printf "\r${BLUE}[${spinstr:$i:1}]${NC} ${msg}..."
            sleep $delay
        done
    done
    wait $pid
    local exit_status=$?
    
    if [ $exit_status -eq 0 ]; then
        printf "\r${GREEN}[${CHECK}]${NC} ${msg} (Done!)\n"
    else
        printf "\r${RED}[${CROSS}]${NC} ${msg} (Failed: $exit_status)\n"
        tput cnorm 2>/dev/null || true
        exit $exit_status
    fi
    tput cnorm 2>/dev/null || true
}

prompt_select() {
    local msg=$1
    local var_name=$2
    shift 2
    local options=("$@")
    
    box_header "$msg" "${CYAN}"
    for i in "${!options[@]}"; do
        box_line "[$((i+1))] ${options[$i]}" "${CYAN}"
    done
    box_footer "${CYAN}"
    
    while true; do
        read -p "[>] Select number: " choice
        if [[ "$choice" -gt 0 && "$choice" -le "${#options[@]}" ]]; then
            eval "$var_name=\"${options[$((choice-1))]}\""
            break
        fi
        echo -e "${RED}[!] Invalid choice.${NC}"
    done
    echo -e "${GREEN}[+] Selected: ${!var_name}${NC}\n"
}


[ ! -d .git ] && git init >/dev/null 2>&1
export NIX_CONFIG="experimental-features = nix-command flakes"
FLAKE_REF="${FLAKE_REF:-git+file:.}"

header "NIXOS PRE-FLIGHT SETUP"

HOSTS_STR=$(nix eval --raw --impure --expr \
  'builtins.concatStringsSep " " (builtins.attrNames (builtins.getFlake (toString ./.)).nixosConfigurations)' \
  2>/dev/null || echo "aorus surface")
read -r -a HOSTS <<< "$HOSTS_STR"
prompt_select "AVAILABLE HOSTS" SELECTED_HOST "${HOSTS[@]}"
HOST=$SELECTED_HOST

MAPFILE=()
while IFS= read -r line; do
    MAPFILE+=("$line")
done < <(lsblk -dpno NAME,SIZE,MODEL | grep -v 'loop' | grep -v 'ram')
prompt_select "AVAILABLE DISKS" SELECTED_DISK_STR "${MAPFILE[@]}"
DISK=$(echo "$SELECTED_DISK_STR" | awk '{print $1}')

box_header "WARNING" "${RED}${BOLD}"
box_line "ALL DATA ON $DISK WILL BE IRRECOVERABLY DESTROYED" "${RED}${BOLD}"
box_footer "${RED}${BOLD}"
read -p "[>] Type YES to continue: " CONFIRM_WIPE
if [[ "$CONFIRM_WIPE" != "YES" ]]; then
    echo -e "${YELLOW}[!] Aborted.${NC}"
    exit 1
fi
echo ""

box_header "SOPS MASTER KEY" "${CYAN}"
box_line "Generate a new SOPS master key?" "${CYAN}"
box_footer "${CYAN}"
read -p "[>] Generate new key? [y/N]: " GEN_MASTER_INPUT
GEN_MASTER="no"
[[ "$GEN_MASTER_INPUT" =~ ^[Yy]$ ]] && GEN_MASTER="yes"
echo ""

box_header "USER CREDENTIALS" "${CYAN}"
box_line "Enter credentials" "${CYAN}"
box_footer "${CYAN}"
read -p "[>] Username: " USERNAME
USERNAME=${USERNAME:-mad}
read -p "[>] Email: " USEREMAIL
while true; do
    read -sp "[>] Password for $USERNAME: " USER_PASS
    echo ""
    [[ -z "$USER_PASS" ]] && continue
    read -sp "[>] Verify password: " USER_PASS_VERIFY
    echo ""
    [[ "$USER_PASS" == "$USER_PASS_VERIFY" ]] && break
    echo -e "${RED}[!] Passwords do not match.${NC}"
done
echo ""

umask 077
mkdir -p secrets
cat > secrets/usercreds.nix <<EOF
{
  userName = "$USERNAME";
  userEmail = "$USEREMAIL";
  device = "$DISK";
}
EOF
git add secrets/usercreds.nix >/dev/null 2>&1
umask 022

export USERNAME HOST DISK FLAKE_REF USER_PASS GEN_MASTER


header "SECRETS BOOTSTRAP"

cat > /tmp/bootstrap-secrets.sh << 'EOF'
#!/usr/bin/env bash
set -e
umask 077
mkdir -p /tmp/sops-nix/ secrets/

HOST_KEY_FILE="/tmp/sops-nix/keys.txt"
export SOPS_AGE_KEY_FILE="$HOST_KEY_FILE"
HOST_PUBKEY_FILE="secrets/${HOST}.pub"

if [[ "$GEN_MASTER" == "yes" ]]; then
    MASTER_KEY_FILE="$HOME/.config/sops/age/keys.txt"
    mkdir -p "$(dirname "$MASTER_KEY_FILE")"
    if [[ ! -f "$MASTER_KEY_FILE" ]]; then
        age-keygen -o "$MASTER_KEY_FILE" 2>/dev/null
        chmod 400 "$MASTER_KEY_FILE"
    fi
    age-keygen -y "$MASTER_KEY_FILE" > secrets/master.pub
    git add secrets/master.pub
fi

[[ ! -f "$HOST_KEY_FILE" ]] && age-keygen -o "$HOST_KEY_FILE" 2>/dev/null
chmod 400 "$HOST_KEY_FILE"
age-keygen -y "$HOST_KEY_FILE" > "$HOST_PUBKEY_FILE"

AGE_RECIPIENTS_YAML=""
for pk_file in secrets/*.pub; do
    if [[ -f "$pk_file" ]]; then
        PUBKEY=$(cat "$pk_file")
        AGE_RECIPIENTS_YAML+="          - $PUBKEY"$'\n'
    fi
done

cat > .sops.yaml <<SOPS
creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
$(printf '%s' "$AGE_RECIPIENTS_YAML")
SOPS
git add .sops.yaml

if [[ ! -f secrets/secrets.yaml ]] || ! grep -q "sops:" secrets/secrets.yaml 2>/dev/null; then
    USER_HASH=$(mkpasswd -m yescrypt -s <<< "$USER_PASS")
    cat <<YAML | sops --encrypt --filename-override secrets/secrets.yaml \
        --input-type yaml --output-type yaml /dev/stdin > secrets/secrets.yaml
git_credentials: |
  https://$USERNAME:placeholder@github.com
user_password_$USERNAME: $USER_HASH
YAML
    git add secrets/secrets.yaml
else
    sops updatekeys --yes secrets/secrets.yaml
    git add secrets/secrets.yaml
fi

if [[ ! -f secrets/rclone.yaml ]] || ! grep -q "sops:" secrets/rclone.yaml 2>/dev/null; then
    cat <<YAML | sops --encrypt --filename-override secrets/rclone.yaml \
        --input-type yaml --output-type yaml /dev/stdin > secrets/rclone.yaml
rclone_client_id: placeholder
rclone_token: placeholder
YAML
    git add secrets/rclone.yaml
else
    sops updatekeys --yes secrets/rclone.yaml
    git add secrets/rclone.yaml
fi
git add secrets/
EOF

chmod +x /tmp/bootstrap-secrets.sh
nix shell nixpkgs#git nixpkgs#age nixpkgs#sops nixpkgs#mkpasswd \
    --command /tmp/bootstrap-secrets.sh &
spinner $! "Bootstrapping secrets and age keys"


header "LOCAL DEPLOY"
echo -e "${CYAN}[*] Running Disko for partitioning...${NC}"
# Write keyfiles for LUKS (avoids interactive prompts during disko)
umask 077
printf '%s' "$USER_PASS" > /tmp/luks-swap.key
printf '%s' "$USER_PASS" > /tmp/luks-root.key

nix run -L 'github:nix-community/disko' -- \
    --mode destroy,format,mount \
    --flake "${FLAKE_REF}#$HOST" \
    --yes-wipe-all-disks

# Cleanup keyfiles
rm -f /tmp/luks-swap.key /tmp/luks-root.key
umask 022

mkdir -p /mnt/persistent/var/lib/sops-nix/
chmod 755 /mnt/persistent/var/lib/sops-nix/
cp "/tmp/sops-nix/keys.txt" /mnt/persistent/var/lib/sops-nix/keys.txt
chmod 400 /mnt/persistent/var/lib/sops-nix/keys.txt

header "GENERATING HARDWARE CONFIG"
nixos-generate-config --no-filesystems --root /mnt --dir /tmp/nixos-hw >/dev/null 2>&1 &
spinner $! "Detecting hardware and generating configuration"
mkdir -p "hosts/$HOST"
cp /tmp/nixos-hw/hardware-configuration.nix "hosts/$HOST/hardware.nix"
git add "hosts/$HOST/hardware.nix"

header "INSTALLING NIXOS"
mkdir -p /mnt/persistent/tmp
export TMPDIR=/mnt/persistent/tmp
echo -e "${CYAN}[*] Starting nixos-install (this may take a while)...${NC}"
nixos-install --flake "${FLAKE_REF}#$HOST" --no-root-password

if [[ -f "$HOME/.config/sops/age/keys.txt" ]]; then
    mkdir -p "/mnt/persistent/home/$USERNAME/.config/sops/age"
    cp "$HOME/.config/sops/age/keys.txt" "/mnt/persistent/home/$USERNAME/.config/sops/age/keys.txt"
    chmod 400 "/mnt/persistent/home/$USERNAME/.config/sops/age/keys.txt"
fi

mkdir -p "/mnt/persistent/home/$USERNAME/nixcfg"
cp -rT "$(pwd)" "/mnt/persistent/home/$USERNAME/nixcfg"

USER_UID=$(chroot /mnt id -u "$USERNAME" 2>/dev/null || echo "1000")
USER_GID=$(chroot /mnt id -g "$USERNAME" 2>/dev/null || echo "100")
chown -R "$USER_UID:$USER_GID" "/mnt/persistent/home/$USERNAME"

header "INSTALLATION COMPLETE"
read -p "[>] Installation finished. Reboot now? [y/N]: " REBOOT_CONFIRM
if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    sync
    reboot
fi