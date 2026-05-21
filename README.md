# NixOS Configuration

## Directory Tree

```
nixcfg/
├── flake.nix                   # Flake entry-point. Declares inputs, mkHost helper,
│                               #   and wires up nixosConfigurations for each host.
├── flake.lock                  # Auto-generated input lock file (pinned dependencies).
│
├── vars/
│   └── default.nix             # Global scalar variables shared across the config:
│                               #   stateVersion, userName ("filip"), timezone, themeName,
│                               #   target device path, and Git platform references.
│
├── lib/
│   └── default.nix             # Custom Nix helper library: mkToggleOption, mkEnableOpt,
│                               #   mkHome, importModulesFromDir, etc.
│
├── hosts/                      # Per-machine configuration — hardware/disko specs and suite choices.
│   ├── aorus/
│   │   ├── default.nix         # Enables desktop suite, sets Aorus-specific options (NVIDIA, Zen kernel).
│   │   ├── hardware.nix        # System hardware config generated for the Aorus laptop.
│   │   └── disko.nix           # Declarative GPT disk layout & Btrfs mountpoints for Aorus.
│   ├── surface/
│   │   ├── default.nix         # Enables desktop suite, sets Surface-specific options (auto-cpufreq).
│   │   ├── hardware.nix        # Generated hardware config for Microsoft Surface Pro.
│   │   └── disko.nix           # Declarative Btrfs disk layout for Surface.
│   └── server/
│       ├── default.nix         # Enables server suite, sets server-specific options (latest kernel).
│       ├── hardware.nix        # System hardware config stub for the headless server.
│       └── disko.nix           # Declarative Btrfs disk layout for the server.
│
├── modules/
│   ├── default.nix             # Auto-import glue: scans modules/nixos/ and modules/home/
│   │                           #   and dynamically imports every .nix file (excluding 'boot' submodules).
│   │
│   ├── suites/                 # Aggregates common modules into reusable configuration profiles.
│   │   ├── desktop-suite.nix   # Bundles desktop apps and imports boot-desktop.nix.
│   │   └── server-suite.nix    # Bundles headless tools and imports boot-server.nix.
│   │
│   ├── nixos/                  # System-level NixOS modules (root/global configurations).
│   │   ├── boot-base.nix       # Core boot settings, sysctl tweaks, and kernel params common to all.
│   │   ├── boot-desktop.nix    # Bootloader and Plymouth visual settings optimized for desktops.
│   │   ├── boot-server.nix     # Speed-optimized headless settings and debug parameters for servers.
│   │   ├── boot.nix            # Deprecated monolithic boot file stub (rendered inactive).
│   │   ├── home-manager.nix    # Configures Home-Manager as a native NixOS module.
│   │   ├── impermanence.nix    # Btrfs rollback-on-boot and opt-in path persistence.
│   │   ├── networking.nix      # Wireless (iwd), Cloudflare DNS, and system firewall configurations.
│   │   ├── security.nix        # Core system security and authentication overrides.
│   │   ├── services.nix        # Primary system services (SSH, resolving, sound, etc.).
│   │   ├── sops.nix            # SOPS-nix secret decryption settings.
│   │   ├── system.nix          # System environment variables, common packages, and zram.
│   │   └── stylix/             # System-wide theming via Stylix and base16 color schemes.
│   │       ├── stylix.nix      # Stylix integration options.
│   │       └── carbon.yaml     # base16 "Carbon" system color scheme palette.
│   │
│   └── home/                   # User-space Home-manager modules (opt-in applications).
│       ├── common.nix          # Declares all modular app options and their merged setups.
│       ├── btop.nix            # btop interactive console system monitor configuration.
│       ├── fastfetch.nix       # fastfetch layout variables and display metrics.
│       ├── fish.nix            # Fish shell prompt styling and system integration.
│       ├── foot.nix            # foot lightweight terminal configuration.
│       ├── fuzzel.nix          # fuzzel Wayland application launcher.
│       ├── git.nix             # Git authentication credentials and signature signing.
│       ├── hypridle.nix        # hypridle system idle daemon hooks.
│       ├── hyprlock.nix        # hyprlock high-fidelity screen locker.
│       ├── keepassxc.nix       # KeePassXC password manager database configurations.
│       ├── mako.nix            # mako Wayland notification daemon style.
│       ├── otter.nix           # otter-launcher configurations.
│       ├── rclone.nix          # rclone cloud sync background tasks.
│       ├── waybar.nix          # Waybar highly-customized status bar.
│       ├── niri/               # Niri Wayland compositor settings and keybind mappings.
│       │   ├── niri.nix        # Core binds, behaviors, and startup scripts.
│       │   └── enhancements.nix # Extra compositor aesthetic tweaks.
│       ├── nvim/               # Neovim lua configuration and plugin loading via nixCats.
│       │   ├── nvim.nix        # nixCats wrapper and core Neovim installation.
│       │   └── lua/            # Neovim init scripting.
│       └── zen/                # Zen Privacy Web Browser configuration.
│           ├── zen.nix         # Zen profiles, extensions, and user.js scripts.
│           ├── tridactyl.nix   # Tridactyl modal keybind rules.
│           └── user.js         # Privacy, telemetry removal, and hardware acceleration configs.
│
├── secrets/
│   ├── secrets.yaml            # SOPS-encrypted password hashes, Git keys, and configurations.
│   ├── rclone.yaml             # SOPS-encrypted storage remote targets.
│   ├── master.pub              # Master age encryption public key.
│   └── surface.pub             # Surface host-specific public age key.
│
├── agents/                     # AI assistant orchestration, setup, and rule documents.
│   ├── AGENTS.md               # Guidelines, operating practices, and workflow models.
│   ├── permissions.md          # Clear permission matrices restricting agent operations.
│   ├── README.md               # Overview of symlink-first agent configuration installer.
│   ├── install-rules.py        # Python tool symlinking rules into IDE profiles.
│   ├── install-cli.md          # Reference snippets for installing CLI helper programs.
│   └── install-skills.md       # Skill templates command snippets for advanced tools.
│
├── Justfile                    # Task runner command specs (deployment, updates, testing).
├── JUSTFILE.md                 # Detailed documentation explaining how to run Justfile tasks.
├── install.sh                  # Modular system bootstrapper and partitioning installer.
├── .sops.yaml                  # SOPS age key decryption path routing laws.
├── .gitignore                  # Git VCS tracking exclusions.
└── .editorconfig               # Uniform formatting settings across file types.
```

---

## Modular Architecture Principles

This system follows these strict operational paradigms:
1. **Host Orthogonality**: Hosts (`hosts/`) only specify hardware specifications (`hardware.nix`), storage properties (`disko.nix`), and import a modular profile suite (`desktop-suite.nix` or `server-suite.nix`).
2. **Opt-in Applications**: App modules (`modules/home/`) declare enabled toggleable options (defaulting to `false`) inside `modules/home/common.nix`. They are cleanly enabled in bulk via Suites.
3. **Explicit Bootloader Paths**: The specialized boot settings (`boot-desktop.nix`, `boot-server.nix`) are ignored by the automatic module importer and are explicitly loaded by their matching suite to avoid bootloader configuration collisions.