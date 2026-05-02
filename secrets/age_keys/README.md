# SOPS Age Keys

This directory contains the public keys (`.pub`) for all devices allowed to decrypt the secrets in this repository.

### How to add a new device:
2. Get the public age key for the device.
   - For a NixOS host using SSH keys: `nix shell nixpkgs#ssh-to-age -c ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`
2. Save the key to a new file here: `${hostname}.pub`
3. Run `sops updatekeys secrets/secrets.yaml` (or run `install.sh`).

### Master Key (Recommended)
Save your main development machine's public key as `master.pub`. This ensures you can always edit secrets from your editor.
