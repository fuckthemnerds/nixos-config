# Agent Permissions

This file defines what operations AI agents can perform in this repository.

Supported agents:
- Antigravity IDE
- OpenCode

## Allowed Operations

✅ **Can do:**
- Modify Nix files in hosts/ and modules/
- Add new packages or services
- Modify home-manager configuration
- Update flake inputs
- Format code with just fmt
- Test configuration with just test
- Create new modules following existing patterns
- Suggest improvements to existing code

## Restricted Operations

⚠️ **Use with caution:**
- Modifying flake.nix (only if necessary)
- Changing hardware.nix files
- Modifying disko.nix (disk configuration)
- Changing sops configuration

## Forbidden Operations

❌ **Cannot do:**
- Commit secrets or credentials
- Delete existing modules without justification
- Modify .gitignore without explanation
- Change repository structure without discussion
- Add dependencies without explaining why
- Modify install.sh without testing

## Security Policies

1. **Secrets**: All sensitive data must use sops-nix
2. **Credentials**: Never hardcode passwords or tokens
3. **Keys**: Private keys must be in secrets/ directory
4. **Validation**: Always run `just test` before finishing

## Tool Access

Agents have access to:
- Nix language and nixpkgs
- Home-manager configuration
- Stylix theming system
- Sops-nix for secrets
- Disko for disk management
- Flake system

Agents do NOT have access to:
- System secrets (unless decrypted by sops-nix)
- Private repositories
- External APIs
- Network operations
