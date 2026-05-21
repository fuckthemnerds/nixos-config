set shell := ["nu", "-c"]

# List all commands
default:
    @just --list

# Show help for a specific command
help command:
    @just --show {{command}}

# =============================================================================
#  Nix
# =============================================================================

# Evaluate and test the flake configuration
[group('nix')]
test:
    nix eval .#nixosConfigurations --show-trace

# Format all Nix files
[group('nix')]
fmt:
    alejandra .

# Update all flake inputs
[group('nix')]
up:
    nix flake update --commit-lock-file

# Update specific input (usage: just upp nixpkgs)
[group('nix')]
upp input:
    nix flake update {{input}} --commit-lock-file

# Check flake for errors
[group('nix')]
check:
    nix flake check

# Show flake outputs
[group('nix')]
show:
    nix flake show

# =============================================================================
#  Build & Deploy
# =============================================================================

[group('local')]
build-aorus:
    nix build .#nixosConfigurations.aorus.config.system.build.toplevel --out-link local/result-aorus

[group('local')]
build-surface:
    nix build .#nixosConfigurations.surface.config.system.build.toplevel --out-link local/result-surface

[group('local')]
build-server:
    nix build .#nixosConfigurations.server.config.system.build.toplevel --out-link local/result-server

[group('local')]
switch-aorus:
    sudo nixos-rebuild switch --flake .#aorus

[group('local')]
switch-surface:
    sudo nixos-rebuild switch --flake .#surface

[group('local')]
switch-server:
    sudo nixos-rebuild switch --flake .#server

[group('local')]
test-aorus:
    sudo nixos-rebuild test --flake .#aorus

[group('local')]
test-surface:
    sudo nixos-rebuild test --flake .#surface

[group('local')]
test-server:
    sudo nixos-rebuild test --flake .#server

# =============================================================================
#  Maintenance
# =============================================================================

# Garbage collect old generations (keep last 7 days)
[group('maintenance')]
gc:
    sudo nix-collect-garbage --delete-older-than 7d

# Garbage collect all unused nix store entries
[group('maintenance')]
gc-aggressive:
    sudo nix-collect-garbage -d

# Show all generations
[group('maintenance')]
generations:
    nix profile history --profile /nix/var/nix/profiles/system

# Verify nix store integrity
[group('maintenance')]
verify-store:
    nix store verify --all

# Repair nix store
[group('maintenance')]
repair-store:
    nix store repair

# =============================================================================
#  Secrets
# =============================================================================

# Decrypt secrets file
[group('secrets')]
secrets-decrypt:
    sops secrets/secrets.yaml

# Edit secrets file
[group('secrets')]
secrets-edit:
    sops secrets/secrets.yaml

# Show secrets status
[group('secrets')]
secrets-status:
    @echo "Secrets managed by sops-nix"
    @echo "Location: secrets/"
    @echo "Config: .sops.yaml"

# =============================================================================
#  Dev & Debugging
# =============================================================================

[group('dev')]
shell:
    nix shell nixpkgs#git nixpkgs#neovim nixpkgs#nushell

[group('dev')]
repl:
    nix repl -f flake:nixpkgs

[group('dev')]
inputs:
    nix flake info

[group('dev')]
metadata:
    nix flake metadata

# =============================================================================
#  Git
# =============================================================================

[group('git')]
ggc:
    git reflog expire --expire-unreachable=now --all
    git gc --prune=now

# Amend last commit without changing message
[group('git')]
game:
    git commit --amend -a --no-edit

[group('git')]
status:
    git status

[group('git')]
log:
    git log --oneline -10

# =============================================================================
#  Workflows
# =============================================================================

# Format, test, and check
[group('workflow')]
check-all:
    just fmt
    just test
    just check

[group('workflow')]
full-update-aorus:
    just up
    just fmt
    just test
    just build-aorus

[group('workflow')]
full-update-surface:
    just up
    just fmt
    just test
    just build-surface

[group('workflow')]
full-update-server:
    just up
    just fmt
    just test
    just build-server
