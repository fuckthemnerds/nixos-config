# Declarative NixOS Configuration

## Overview

This repository houses my declarative NixOS configurations, managed with Nix flakes. It is designed for absolute reproducibility, clean modular division, and seamless ease of management across multiple hosts—ranging from high-performance desktop workstations to dedicated server instances. The architecture leverages a strict modular separation between hardware layouts, core OS modules, user-space tools, and reusable configuration profiles (Suites).

Key features include:
- **Declarative System Management**: Entire operating system configured using NixOS.
- **Reproducible Environments**: Strictly pinned dependencies using Nix flakes and lockfiles.
- **Modular Design**: Complete separation of concerns for simplified upgrades and maintenance.
- **Btrfs Impermanence**: Root filesystem rolls back to a blank snapshot on every single boot, using explicit Btrfs persistence for essential data.
- **Secrets Management**: Secure, robust, age-based file encryption via `sops-nix`.
- **Task Automation**: Streamlined building and switching workflows using the custom `Justfile`.
- **AI Agent Collaboration**: Standardized baseline parameters for AI pair programming inside `agents/`.

---

## Directory Structure

The configuration is systematically organized as follows:
- `flake.nix`: Main flake entrypoint defining inputs, `mkHost` generators, and system outputs.
- `vars/`: Global shared parameters (username, timezone, theme definitions, and target devices).
- `lib/`: Domain-specific helper utilities extending the standard Nix library.
- `hosts/`: Host-specific definitions containing hardware specs, disk partitioning, and suite choices.
- `modules/`: Reusable NixOS modules, Home-Manager applications, and environment Suites.
- `secrets/`: SOPS-encrypted credentials, SSH files, and public age keys.
- `agents/`: AI assistant workspace, guidelines, permissions, and tool configuration.

For a comprehensive file-by-file breakdown of the workspace, please refer to [STRUCTURE.md](STRUCTURE.md).

---

## Installation

To deploy this configuration on a fresh machine:
1. **Prepare Installation Media**: Boot into a minimal NixOS installer environment.
2. **Partition Disks**: Utilize `disko` declarations (defined in `hosts/<hostname>/disko.nix`) to format target drives.
3. **Run Installer**: Execute the customized bootstrap shell script specifying the target host name:
   ```bash
   sudo ./install.sh <hostname>
   ```
   *Example: `sudo ./install.sh aorus`*

---

## Usage and Task Execution

All common management routines are handled cleanly through `just`:
- `just build-<hostname>`: Build a specific host's NixOS derivation without applying.
- `just switch-<hostname>`: Build and apply a target configuration to the local host.
- `just test-<hostname>`: Dry-run activation to test configurations.
- `just fmt`: Formats all Nix expressions in the workspace with `alejandra`.
- `just up`: Update all flake locked inputs to their latest versions.

For a detailed review of all commands, refer to the [JUSTFILE.md](JUSTFILE.md) guide.

---

## Contributing and AI Workflows

Contributions are welcome! Please adhere to the modular structure and code guidelines. For pair-programming using AI agents (such as Antigravity IDE and OpenCode), consult the [AGENTS.md](agents/AGENTS.md) rules.

---

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) (if present) for details.
