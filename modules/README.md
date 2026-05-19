# 🧩 System & Home Modules

This directory contains the central, reusable modules that define system settings (under `core/`) and user preferences/home-manager configurations (under `home/`).

---

## 🏗️ Structure

- **`core/`** - Core system-wide configs (boot configuration, networking, sops-nix integration, security policies, resource management).
- **`home/`** - Home-Manager application declarations and dotfiles (terminals like foot, fish shell, fuzzel, window manager / compositor niri, git, otter-launcher, waybar, and common applications).
- **`default.nix`** - The entrypoint containing a custom functional recusive scanner that auto-imports every module under this directory.

---

## ⚡ How it Works: Auto-Import

We use a dynamic importing scheme in `modules/default.nix`. All files ending in `.nix` (excluding `default.nix` itself) found within this directory tree are recursively auto-discovered and imported system-wide.

> [!NOTE]
> This means you **never** need to manually add an import statement to `modules/default.nix` when creating a new module. Simply placing the `.nix` file in the appropriate directory will register it automatically!

---

## 🛠️ Common Workflows

### ➕ Adding a New System Module
1. Create a new `.nix` file under `core/` (e.g., `modules/core/my-service.nix`).
2. Define standard NixOS module structure:
   ```nix
   { pkgs, ... }: {
     services.my-service.enable = true;
   }
   ```
3. Run `just fmt` to format the file and `just check` to ensure correctness.

### ➕ Adding an Opt-In User App Module
1. Create a new `.nix` file under `home/` (e.g., `modules/home/my-app.nix`).
2. Declare it as a configurable option (opt-out by default) inside `options.apps`:
   ```nix
   { config, lib, pkgs, ... }:
   let
     cfg = config.apps.my-app;
   in {
     options.apps.my-app.enable = lib.mkOption {
       type = lib.types.bool;
       default = false;
       description = "Enable my-app custom config";
     };

     config = lib.mkIf cfg.enable {
       # Configuration code
     };
   }
   ```
3. Opt-in to this application inside your host configuration under `hosts/<hostname>/default.nix`:
   ```nix
   apps.my-app.enable = true;
   ```

---

## 📐 Guidelines

- **Keep core modules generalized:** Core modules apply system-wide; avoid hardcoding specific user environments or host variables.
- **Opt-in app design:** Use option switches for individual applications (`options.apps.<app-name> = { ... }`) to let hosts decide which system utilities or graphical packages to load.
- **Document with care:** Use inline comments sparingly to describe *why* a configuration is used rather than *what* it is doing.
