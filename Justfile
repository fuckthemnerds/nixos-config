# Just is a command runner, similar to Make but simpler
# Use nushell for shell commands
# To use this justfile, you need: nix shell nixpkgs#just nixpkgs#nushell

set shell := ["nu", "-c"]

############################################################################
#
# Common commands (suitable for all machines)
#
############################################################################

# List all the just commands
default:
    @just --list

# Show help for a specific command
help command:
    @just --show {{command}}

############################################################################
#
# NixOS Build & Test Commands
#
############################################################################

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

# Update specific input
# Usage: just upp nixpkgs
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

############################################################################
#
# Local Machine Deployment
#
############################################################################

# Get the current hostname
[group('local')]
hostname:
    @hostname

# Build configuration for local machine (aorus)
[group('local')]
build-aorus:
    nix build .#nixosConfigurations.aorus.config.system.build.toplevel

# Build configuration for surface
[group('local')]
build-surface:
    nix build .#nixosConfigurations.surface.config.system.build.toplevel

# Switch local machine to new configuration (aorus)
[group('local')]
switch-aorus:
    sudo nixos-rebuild switch --flake .#aorus

# Switch local machine to new configuration (surface)
[group('local')]
switch-surface:
    sudo nixos-rebuild switch --flake .#surface

# Test configuration without switching (aorus)
[group('local')]
test-aorus:
    sudo nixos-rebuild test --flake .#aorus

# Test configuration without switching (surface)
[group('local')]
test-surface:
    sudo nixos-rebuild test --flake .#surface

############################################################################
#
# Cleanup & Maintenance
#
############################################################################

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

############################################################################
#
# Secrets Management (sops-nix)
#
############################################################################

# Decrypt secrets file
[group('secrets')]
secrets-decrypt:
    sops secrets/secrets.yaml

# Edit secrets file
[group('secrets')]
secrets-edit:
    sops -e secrets/secrets.yaml

# Show secrets status
[group('secrets')]
secrets-status:
    @echo "Secrets managed by sops-nix"
    @echo "Location: secrets/"
    @echo "Config: .sops.yaml"

############################################################################
#
# Development & Debugging
#
############################################################################

# Enter a nix shell with all tools
[group('dev')]
shell:
    nix shell nixpkgs#git nixpkgs#neovim nixpkgs#nushell

# Open nix repl for debugging
[group('dev')]
repl:
    nix repl -f flake:nixpkgs

# Show flake inputs
[group('dev')]
inputs:
    nix flake info

# Show flake metadata
[group('dev')]
metadata:
    nix flake metadata

############################################################################
#
# Git Operations
#
############################################################################

# Git garbage collection
[group('git')]
ggc:
    git reflog expire --expire-unreachable=now --all
    git gc --prune=now

# Amend last commit without changing message
[group('git')]
game:
    git commit --amend -a --no-edit

# Show git status
[group('git')]
status:
    git status

# Show git log
[group('git')]
log:
    git log --oneline -10

############################################################################
#
# Workflow Shortcuts
#
############################################################################

# Complete workflow: format, test, and show status
[group('workflow')]
check-all:
    @echo "🔍 Checking configuration..."
    just fmt
    just test
    just check
    @echo "✅ All checks passed!"

# Build and test aorus
[group('workflow')]
build-test-aorus:
    @echo "🔨 Building aorus configuration..."
    just build-aorus
    @echo "✅ Build successful!"
    @echo "🧪 Testing configuration..."
    just test-aorus
    @echo "✅ Test successful!"

# Build and test surface
[group('workflow')]
build-test-surface:
    @echo "🔨 Building surface configuration..."
    just build-surface
    @echo "✅ Build successful!"
    @echo "🧪 Testing configuration..."
    just test-surface
    @echo "✅ Test successful!"

# Update, format, test, and build
[group('workflow')]
full-update-aorus:
    @echo "📦 Updating flake inputs..."
    just up
    @echo "✅ Inputs updated!"
    @echo "📝 Formatting code..."
    just fmt
    @echo "✅ Code formatted!"
    @echo "🧪 Running tests..."
    just test
    @echo "✅ Tests passed!"
    @echo "🔨 Building configuration..."
    just build-aorus
    @echo "✅ Build successful!"
    @echo "🎉 Ready to switch!"

# Full update for surface
[group('workflow')]
full-update-surface:
    @echo "📦 Updating flake inputs..."
    just up
    @echo "✅ Inputs updated!"
    @echo "📝 Formatting code..."
    just fmt
    @echo "✅ Code formatted!"
    @echo "🧪 Running tests..."
    just test
    @echo "✅ Tests passed!"
    @echo "🔨 Building configuration..."
    just build-surface
    @echo "✅ Build successful!"
    @echo "🎉 Ready to switch!"
