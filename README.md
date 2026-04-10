# NixOS Configuration (Dendritic architecture)

This repository contains a refactored, impermanent, dual-host NixOS configuration for an Aorus 17XD and a Surface Pro 8.

## 🚀 Bootstrap Installation

To install this configuration from a PRIVATE repository, boot into a NixOS Live ISO and follow these steps:

### 1. Setup SSH Authentication
Since the repo is private, you need an SSH key added to your agent to reach GitHub:
```bash
# Start agent and add your existing key (from a USB or generated fresh)
eval "$(ssh-agent -s)"
ssh-add /path/to/your/private_key 

# Verify connection
ssh -T git@github.com
```

### 2. Run the Installer
```bash
# Optional: Set experimental features
export NIX_CONFIG="extra-experimental-features = nix-command flakes"

# Run directly via SSH flake URL
nix run git+ssh://git@github.com/my-user/nixos-config#install
```

> [!NOTE]
> The repository uses a **Local Identity** pattern. Your actual username (`filip`) is NOT in Git; it is generated locally during installation.

## 🛠️ Post-Installation Setup

After the first boot, you need to manually set up your Git identity and SSH keys to push the newly generated secrets and hardware stub back to your repository.

### 1. Generate a User SSH Key
Generate a new key specifically for GitHub:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_github
```

### 2. Add Key to SSH Agent
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_github
```

### 3. Add to GitHub
Copy your public key:
```bash
cat ~/.ssh/id_github.pub
```
Go to [GitHub Settings > SSH and GPG keys](https://github.com/settings/keys) and add it.

### 4. Push Generated Files
Your installation creates a hardware stub and encrypted secrets. You must push these to keep your repo synced:
```bash
cd /etc/nixos # Or your persistence source
git add .
git commit -m "chore: add hardware-stub and secrets for $(hostname)"
git push origin master
```

## ❄️ Deployment

Once installed, use the included deployment script for subsequent updates:
```bash
./deploy.sh
```
