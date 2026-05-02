#!/usr/bin/env bash
set -e

# ==============================================================================
# UI HELPERS & STYLING
# ==============================================================================

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Symbols
CHECK="✔"
CROSS="✘"
INFO="ℹ"
WARN="⚠"

# Header Function
header() {
    local title=$1
    local width=70
    local padding=$(( (width - ${#title} - 2) / 2 ))
    echo -e "\n${BLUE}┌$(printf '─%.0s' $(seq 1 $width))┐${NC}"
    printf "${BLUE}│${NC}${BOLD}%*s %s %*s${NC}${BLUE}│${NC}\n" $padding "" "$title" $padding ""
    echo -e "${BLUE}└$(printf '─%.0s' $(seq 1 $width))┘${NC}\n"
}

# Spinner Function
# Usage: command & spinner $! "Message"
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local msg=$2
    
    # Hide cursor
    tput civis 2>/dev/null || true
    
    while ps -p $pid > /dev/null; do
        for i in $(seq 0 9); do
            printf "\r${BLUE}[${spinstr:$i:1}]${NC} ${msg}..."
            sleep $delay
        done
    done
    
    # Check exit status of the PID
    wait $pid
    local exit_status=$?
    
    if [ $exit_status -eq 0 ]; then
        printf "\r${GREEN}[${CHECK}]${NC} ${msg} (Done!)\n"
    else
        printf "\r${RED}[${CROSS}]${NC} ${msg} (Failed with exit code $exit_status)\n"
        tput cnorm 2>/dev/null || true
        exit $exit_status
    fi
    
    # Show cursor
    tput cnorm 2>/dev/null || true
}

# Prompt Helper
prompt_select() {
    local msg=$1
    local var_name=$2
    shift 2
    local options=("$@")
    
    echo -e "${CYAN}┌─[ $msg ]──────────────────────────────────────────────${NC}"
    for i in "${!options[@]}"; do
        printf "${CYAN}│${NC} [%d] %s\n" "$((i+1))" "${options[$i]}"
    done
    echo -e "${CYAN}└──────────────────────────────────────────────────────────────────${NC}"
    
    while true; do
        read -p "[>] Select number: " choice
        if [[ "$choice" -gt 0 && "$choice" -le "${#options[@]}" ]]; then
            eval "$var_name=\"${options[$((choice-1))]}\""
            break
        fi
    done
    echo -e "${GREEN}[+] Selected: ${!var_name}${NC}\n"
}

# ==============================================================================
# INITIALIZATION
# ==============================================================================

[ ! -d .git ] && git init >/dev/null 2>&1

export NIX_CONFIG="experimental-features = nix-command flakes"
FLAKE_REF="${FLAKE_REF:-git+file:.}"

header "NIXOS PRE-FLIGHT SETUP"

# Host Selection
HOSTS_STR=$(nix eval --raw --impure --expr \
  'builtins.concatStringsSep " " (builtins.attrNames (builtins.getFlake (toString ./.)).nixosConfigurations)' \
  2>/dev/null || echo "aorus surface")
read -r -a HOSTS <<< "$HOSTS_STR"

prompt_select "AVAILABLE HOSTS" SELECTED_HOST "${HOSTS[@]}"
HOST=$SELECTED_HOST

# Disk Selection
MAPFILE=()
while IFS= read -r line; do
    MAPFILE+=("$line")
done < <(lsblk -dpno NAME,SIZE,MODEL | grep -v 'loop' | grep -v 'ram')

prompt_select "AVAILABLE DISKS" SELECTED_DISK_STR "${MAPFILE[@]}"
DISK=$(echo "$SELECTED_DISK_STR" | awk '{print $1}')

echo -e "${RED}${BOLD}┌──────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${RED}${BOLD}│ WARNING: ALL DATA ON $DISK WILL BE IRRECOVERABLY DESTROYED       │${NC}"
echo -e "${RED}${BOLD}└──────────────────────────────────────────────────────────────────┘${NC}"
read -p "[>] Type YES to continue: " CONFIRM_WIPE
if [[ "$CONFIRM_WIPE" != "YES" ]]; then
    echo -e "${YELLOW}[!] Aborted.${NC}"
    exit 1
fi
echo ""

# SOPS Master Key
echo -e "${CYAN}┌─[ SOPS MASTER KEY ]──────────────────────────────────────────────${NC}"
read -p "│ [>] Generate a new SOPS master key for decryption? [y/N]: " GEN_MASTER_INPUT
echo -e "${CYAN}└──────────────────────────────────────────────────────────────────${NC}"
if [[ "$GEN_MASTER_INPUT" =~ ^[Yy]$ ]]; then
    GEN_MASTER="yes"
else
    GEN_MASTER="no"
fi
echo ""

# User Credentials
echo -e "${CYAN}┌─[ USER CREDENTIALS ]─────────────────────────────────────────────${NC}"
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
    echo -e "${RED}│ [!] Passwords do not match.${NC}"
done
echo -e "${CYAN}└──────────────────────────────────────────────────────────────────${NC}"
echo ""

# Save user credentials
umask 077
mkdir -p secrets
cat > secrets/usercreds.nix <<EOF
{
  userName = "$USERNAME";
  userEmail = "$USEREMAIL";
}
EOF
git add secrets/usercreds.nix >/dev/null 2>&1

# Export variables for the sub-shell
export USERNAME HOST DISK FLAKE_REF USER_PASS GEN_MASTER

# ==============================================================================
# SECRETS BOOTSTRAP
# ==============================================================================

header "SECRETS BOOTSTRAP"

# Run in a subshell with a temporary script to keep things clean
cat > /tmp/bootstrap-secrets.sh << 'EOF'
#!/usr/bin/env bash
set -e
# Note: Functions from parent shell are not automatically available here
# We use simple commands instead

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
        age-keygen -o "$MASTER_KEY_FILE" 2>/dev/null
        chmod 400 "$MASTER_KEY_FILE"
    fi
    MASTER_PUBKEY=$(age-keygen -y "$MASTER_KEY_FILE")
    echo "$MASTER_PUBKEY" > secrets/master.pub
    git add secrets/master.pub
fi

# 1. Handle Host Age Key
if [[ ! -f "$HOST_KEY_FILE" ]]; then
    age-keygen -o "$HOST_KEY_FILE" 2>/dev/null
fi
chmod 400 "$HOST_KEY_FILE"

THIS_HOST_PUBKEY=$(age-keygen -y "$HOST_KEY_FILE")
echo "$THIS_HOST_PUBKEY" > "$HOST_PUBKEY_FILE"

# 2. Update .sops.yaml
ALL_PUBKEYS=()
AGE_RECIPIENTS_YAML=""
for pk_file in secrets/*.pub; do
    if [[ -f "$pk_file" ]]; then
        PUBKEY=$(cat "$pk_file")
        AGE_RECIPIENTS_YAML+="          - $pk"$'\n'
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

# 3. Encrypt/Update secrets
if [[ ! -f secrets/secrets.yaml ]] || ! grep -q "sops:" secrets/secrets.yaml 2>/dev/null; then
    USER_HASH=$(mkpasswd -m yescrypt -s <<< "$USER_PASS")
    cat <<YAML | sops --encrypt \
        --filename-override secrets/secrets.yaml \
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
    cat <<YAML | sops --encrypt \
        --filename-override secrets/rclone.yaml \
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

# ==============================================================================
# LOCAL DEPLOY
# ==============================================================================

header "LOCAL DEPLOY"

echo -e "${CYAN}[*] Running Disko for partitioning...${NC}"
# Corrected disko command: using --argstr device to pass the disk path
nix run -L 'github:nix-community/disko' -- \
    --mode destroy,format,mount \
    --flake "${FLAKE_REF}#$HOST" \
    --argstr device "$DISK"

# Provision the key to the new system
mkdir -p /mnt/persistent/var/lib/sops-nix/
chmod 755 /mnt/persistent/var/lib/sops-nix/
cp "/tmp/sops-nix/keys.txt" /mnt/persistent/var/lib/sops-nix/keys.txt
chmod 400 /mnt/persistent/var/lib/sops-nix/keys.txt

# ==============================================================================
# HARDWARE CONFIGURATION
# ==============================================================================

header "GENERATING HARDWARE CONFIG"

nixos-generate-config --no-filesystems --root /mnt --dir /tmp/nixos-hw >/dev/null 2>&1 &
spinner $! "Detecting hardware and generating configuration"

mkdir -p "hosts/$HOST"
cp /tmp/nixos-hw/hardware-configuration.nix "hosts/$HOST/hardware.nix"
git add "hosts/$HOST/hardware.nix"

# ==============================================================================
# NIXOS INSTALLATION
# ==============================================================================

header "INSTALLING NIXOS"

# Space optimization: Use the newly mounted persistent storage for temporary build files
# to avoid filling up the installer's RAM-based /tmp.
mkdir -p /mnt/persistent/tmp
export TMPDIR=/mnt/persistent/tmp

echo -e "${CYAN}[*] Starting nixos-install (this may take a while)...${NC}"
nixos-install --flake "${FLAKE_REF}#$HOST" --no-root-password

# Post-install: copy the config to the new system
mkdir -p "/mnt/persistent/home/$USERNAME/"
cp -r "$(pwd)" "/mnt/persistent/home/$USERNAME/nixcfg"
if chroot /mnt id "$USERNAME" >/dev/null 2>&1; then
    chroot /mnt chown -R "$USERNAME:users" "/mnt/persistent/home/$USERNAME/nixcfg" || true
fi

header "INSTALLATION COMPLETE"

echo -e "${CYAN}┌─[ SYSTEM REBOOT ]────────────────────────────────────────────────${NC}"
read -p "│ [>] Reboot now? [y/N] " REBOOT_CONFIRM
echo -e "${CYAN}└──────────────────────────────────────────────────────────────────${NC}"
if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
    sync
    reboot
fi