# NixOS Configuration (Dendritic architecture)

This repository contains a refactored, impermanent, dual-host NixOS configuration for an Aorus 17XD and a Surface Pro 8.

## 🚀 Bootstrap Installation

To install this configuration, boot into a NixOS Live ISO and follow these steps:

### 1. (Recommended) Public Bootstrap
For the easiest installation, temporarily make your repository **Public** on GitHub and run:
```bash
# Optional: Set experimental features
export NIX_CONFIG="extra-experimental-features = nix-command flakes"

# Run directly from your public repo
nix run github:YOUR_USER/YOUR_REPO#install
```

### 2. (Alternative) Private Bootstrap
If you prefer to keep the repo **Private**, follow the [Private Setup Guide](file:///c:/Users/mad/.gemini/antigravity/scratch/nixos-config/docs/DEPLOYMENT.md) which requires setting up SSH keys on the Live ISO.

> [!NOTE]
> **Privacy Persistence**: Because we use a **Local Identity Pattern**, your actual username (`filip`) is NEVER in Git. It is generated locally during installation. Even if the repo is public, your identity remains hidden.

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
