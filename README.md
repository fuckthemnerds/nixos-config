<h2 align="center">:snowflake: Filip's Nix Config :snowflake:</h2>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<p align="center">
    <a href="https://nixos.org/">
        <img src="https://img.shields.io/badge/NixOS-26.05-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
    <a href="https://github.com/nix-community/home-manager">
        <img src="https://img.shields.io/badge/Home%20Manager-learning-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
</p>

> My configuration is highly modular, automated, and secure. If you are new to NixOS and want to explore how I structure my setup, feel free to use this repository as a comprehensive reference guide.

This repository is home to the Nix code that builds my systems:

1. **NixOS Desktops**: NixOS configurations with Home-Manager, Niri compositor, sops-nix, impermanence, etc.
2. **Modular Architecture**: Automatically recursively scanned and imported Nix modules located under `./modules/`.

See [./hosts](./hosts) for details of each host.

---

## Why NixOS & Flakes?

Nix allows for easy-to-manage, collaborative, and fully reproducible deployments. This means that once something is set up and configured once, it works forever. With Flakes, managing external inputs, system updates, and formatting is standardized and simple.

---

## Components

This config uses the following premium modern components:

| Feature | Component | Description |
| :--- | :--- | :--- |
| **Window Manager** | [Niri][Niri] | A scrollable-tiling Wayland window manager |
| **Terminal Emulator** | [foot][foot] | Fast, lightweight, and minimalistic Wayland terminal emulator |
| **Status Bar** | [Waybar][Waybar] | Highly customizable Wayland bar |
| **Notification Daemon** | [Mako][Mako] | Lightweight Wayland notification daemon |
| **Application Launcher** | [Fuzzel][Fuzzel] + [Otter Launcher][Otter] | Wayland-native application launchers |
| **Display Manager** | [Ly][Ly] | A minimalist TUI display manager |
| **Color Scheme & Theme** | [Stylix][Stylix] | System-wide styling and color synchronization |
| **System Monitor** | [Btop][Btop] | Modern, feature-rich terminal resource monitor |
| **Shell** | [Fish][Fish] | Smart and user-friendly command-line shell |
| **Editor / IDE** | [Neovim][Neovim] | Extensible modal text editor |
| **Web Browser** | [Zen Browser][Zen] | Privacy-focused modern browser |
| **Secrets Management** | [sops-nix][Sops] | Decrypted files via age SSH keybindings |
| **Filesystem & Persistence** | [Impermanence][Impermanence] | Ephemeral root filesystem on Btrfs with rollback |

---

## Screenshots

<p align="center"><i>Premium dark theme synced system-wide using Stylix Carbon scheme.</i></p>

---

## Secrets Management

Secrets are managed with `sops-nix` and `age` keys. 
See [./secrets](./secrets) for details of the decryption and editing workflow.

---

## How to Deploy this Flake?

> :red_circle: **IMPORTANT**: **You should NOT deploy this flake directly on your machine.** This flake contains machine-specific hardware layouts (like Disko partition tables, Prime Nvidia configurations, etc.) and expects sops-nix secrets, which are not suitable for generic hardware. Use this repository purely as a reference to build your own configuration.

### Deploying a Configuration

To apply changes to one of the target hosts:

```bash
# Apply to primary gaming and development desktop (aorus)
just switch-aorus

# Apply to Microsoft Surface Pro (surface)
just switch-surface
```

For quick local testing and formatting:

```bash
# Format Nix files in the repository
just fmt

# Evaluate host configuration to ensure no syntax/eval errors
just test
```

---

## References

Other configurations that inspired this setup:
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [hlissner/dotfiles](https://github.com/hlissner/dotfiles)

[Niri]: https://github.com/YaLTeR/niri
[foot]: https://codeberg.org/dnkl/foot
[Waybar]: https://github.com/Alexays/Waybar
[Mako]: https://github.com/emersion/mako
[Fuzzel]: https://codeberg.org/dnkl/fuzzel
[Otter]: https://github.com/kuokuo123/otter-launcher
[Ly]: https://github.com/apognu/ly
[Stylix]: https://github.com/danth/stylix
[Btop]: https://github.com/aristocratos/btop
[Fish]: https://github.com/fish-shell/fish-shell
[Neovim]: https://github.com/neovim/neovim
[Zen]: https://github.com/zen-browser/desktop
[Sops]: https://github.com/Mic92/sops-nix
[Impermanence]: https://github.com/nix-community/impermanence
