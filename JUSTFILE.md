# Justfile Usage Guide

This project uses `just` as a task runner for common operations.

## Installation

```bash
nix shell nixpkgs#just nixpkgs#nushell
```

## Common Commands

### Development
- `just fmt` - Format all Nix files
- `just test` - Test the flake configuration
- `just check` - Check for flake errors
- `just check-all` - Run all checks

### Building
- `just build-aorus` - Build aorus configuration
- `just build-surface` - Build surface configuration

### Deployment
- `just switch-aorus` - Apply changes to aorus
- `just switch-surface` - Apply changes to surface
- `just test-aorus` - Test without applying (aorus)
- `just test-surface` - Test without applying (surface)

### Updates
- `just up` - Update all flake inputs
- `just upp nixpkgs` - Update specific input
- `just full-update-aorus` - Complete workflow for aorus
- `just full-update-surface` - Complete workflow for surface

### Maintenance
- `just gc` - Garbage collect (keep 7 days)
- `just gc-aggressive` - Aggressive garbage collection
- `just generations` - Show all generations
- `just verify-store` - Verify nix store

### Secrets
- `just secrets-decrypt` - Decrypt secrets
- `just secrets-edit` - Edit secrets
- `just secrets-status` - Show secrets status

## Workflow Examples

### Update and deploy to aorus
```bash
just full-update-aorus
just switch-aorus
```

### Quick test
```bash
just fmt
just test
just check
```

### Cleanup
```bash
just gc
```

## Tips

- Use `just --list` to see all available commands
- Use `just --show <command>` to see what a command does
- Commands are grouped by category for organization
- Use workflow commands for common multi-step operations
