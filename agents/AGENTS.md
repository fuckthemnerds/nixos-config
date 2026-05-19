# AGENTS.md - Guidelines for AI Coding Agents

This file defines the default operating guide for AI agents working in this NixOS configuration repository.

Supported agents:
- Antigravity IDE
- OpenCode

## Scope and Repository Model

This repository manages:
- NixOS hosts (aorus desktop, surface laptop)
- Home-manager profiles for user configuration
- System modules for common functionality
- Secrets management via sops-nix
- Theme management via stylix

## Ground Rules for Agents

1. **Prefer `just` tasks`** over ad-hoc commands when an equivalent task exists.
   - Use `just fmt` instead of manual nixfmt
   - Use `just test` instead of nix eval
   - Use `just build-aorus` instead of raw nix build

2. **Make the smallest reasonable change** - avoid drive-by refactors.
   - Only modify files necessary for the requested feature
   - Don't reorganize modules unless explicitly asked
   - Preserve existing structure and naming conventions

3. **Do not commit secrets, generated credentials, or private keys.**
   - Use sops-nix for any sensitive data
   - Never add plaintext passwords or API keys
   - Reference `secrets/` directory for secret management

4. **Preserve platform guards** and host naming conventions.
   - Keep host-specific configurations in `hosts/aorus/` and `hosts/surface/`
   - Use proper module organization (core vs home)
   - Don't mix host-specific and shared configuration

5. **Run formatting and evaluation checks** for touched areas before finishing.
   - Run `just fmt` on modified Nix files
   - Run `just test` to verify configuration
   - Run `just check` to verify flake integrity

## Change Review Checklist (for agents)

Before finishing, verify:

1. Change is scoped to requested behavior
2. `just fmt` applied to modified files
3. `just test` run and passes
4. No secrets or machine-specific artifacts added
5. User-facing summary includes what changed and what was validated

## Repository Structure

```
.
├── hosts/              # Host-specific configurations
│   ├── aorus/          # Desktop machine
│   └── surface/        # Laptop machine
├── modules/            # Shared modules
│   ├── core/           # System-wide modules
│   ├── home/           # Home-manager modules
│   └── default.nix     # Module imports
├── secrets/            # Secrets (sops-nix)
├── themes/             # Stylix themes
├── flake.nix           # Flake definition
├── Justfile            # Task runner
└── agents/             # Agent configuration
```

## Common Tasks

### Adding a new package
1. Edit appropriate module in `modules/core/` or `modules/home/`
2. Run `just fmt`
3. Run `just test`
4. Suggest: `just build-aorus` to test locally

### Modifying host-specific config
1. Edit `hosts/aorus/` or `hosts/surface/`
2. Run `just fmt`
3. Run `just test`
4. Suggest: `just switch-aorus` or `just switch-surface`

### Adding a new module
1. Create new file in `modules/core/` or `modules/home/`
2. Add import to `modules/default.nix`
3. Run `just fmt`
4. Run `just test`

### Managing secrets
1. Edit with: `just secrets-edit`
2. Secrets are automatically decrypted by sops-nix
3. Never commit plaintext secrets

## Useful Commands for Agents

```bash
just fmt              # Format code
just test             # Test configuration
just check            # Check flake
just build-aorus      # Build aorus config
just build-surface    # Build surface config
just switch-aorus     # Apply to aorus
just switch-surface   # Apply to surface
just up               # Update inputs
just gc               # Cleanup
```

## Example Workflow

User: "Add Firefox to the desktop"

Agent response:
1. Modifies `modules/home/default.nix` to add Firefox
2. Runs `just fmt` to format
3. Runs `just test` to verify
4. Suggests: "I've added Firefox to your home-manager configuration. To apply:
   ```bash
   just switch-aorus
   ```"

## Notes

- Always use the Justfile for common operations
- Keep changes minimal and focused
- Test before suggesting deployment
- Use sops-nix for any secrets
- Preserve the existing module structure
