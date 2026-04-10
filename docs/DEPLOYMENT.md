# ── DEPLOYMENT GUIDE ──────────────────────────────────────────────────────────
# How to install and update this configuration on your machines.

This repository supports two primary workflows: **Initial Installation** (for new machines) and **Routine Deployment** (for existing machines).

## ── PREREQUISITES ─────────────────────────────────────────────────────────────

-   **Target Machines**: Aorus 17XD or Surface Pro 8.
-   **Method**: All deployments use **Nix Flakes** and **Impermanence**.
-   **Hardware**: Ensure you are booted from a NixOS Live ISO for new installs.

## ── INITIAL INSTALLATION ──────────────────────────────────────────────────────

To set up a fresh machine with the "Dendritic" architecture (Btrfs subvolumes + Impermanence), follow these steps:

1.  **Boot Phase**: Boot into a NixOS Live ISO.
2.  **Clone Phase**:
    ```bash
    git clone https://github.com/fuckthemnerds/nixos-config.git
    cd nixos-config
    ```
3.  **Bootstrap Phase**:
    ```bash
    sudo bash install.sh
    ```
    *   **Disk Selection**: Choose your target NVMe drive.
    *   **Host Selection**: Type `aorus` or `surface`.
    *   **Secrets**: The script will automatically generate SSH host keys and bootstrap SOPS secrets.
    *   **Hardware**: A hardware stub will be generated for your specific machine.

## ── ROUTINE DEPLOYMENT ────────────────────────────────────────────────────────

For day-to-day updates and configuration changes on an already installed system:

1.  **Modify**: Make your changes to the `.nix` files.
2.  **Deploy**:
    ```bash
    cd /persistent/etc/nixos # Or your local clone
    sudo bash deploy.sh
    ```
    The `deploy.sh` script handles the following automatically:
    - **Formatting**: Runs `alejandra` to ensure the "Strict Blocky" style.
    - **Staging**: Runs `git add .` (necessary for Flakes to see new files).
    - **Building**: Uses `nh os switch` for a clean, visual build process.
    - **Diffing**: Displays a visual diff of changes between the current and new system.

## ── SECRET MANAGEMENT ─────────────────────────────────────────────────────────

We use **sops-nix** with **age** keys derived from SSH host keys.

-   **System Secrets**: Stored in `secrets/secrets.yaml`.
-   **Editing**:
    ```bash
    sops secrets/secrets.yaml
    ```
-   **Persistence**: Host keys are stored in `/persistent/etc/ssh` to survive root wpes.

## ── IMPERMANENCE & STATE ──────────────────────────────────────────────────────

This system wipes the root (`/`) on every boot. Only data in the following locations is preserved:

-   `/persistent`: System state, configuration, and SSH keys.
-   `/persistent/home`: User data and personal configurations.

> [!WARNING]
> Any data not explicitly listed in `system/impermanence.nix` or mapped to `/persistent` will be **DELETED** on reboot.
