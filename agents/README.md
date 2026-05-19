# agents

Reusable, symlink-first agent resources for this NixOS configuration.

Supported agents:
- Antigravity IDE
- OpenCode

This directory is the canonical source for baseline agent rules and supporting command references.

## What this directory contains

- `AGENTS.md` - Global baseline rules for coding agents
- `permissions.md` - Permission policies for agent tool access
- `install-rules.py` - Script to install baseline rules to agent config directories
- `install-cli.md` - Curated CLI install/update command snippets
- `install-skills.md` - Curated agent skills command snippets

## Core workflow

1. Maintain shared rules in `agents/AGENTS.md`
2. Define permission policies in `agents/permissions.md`
3. Run `install-rules.py` to refresh symlinks in local agent homes
4. Use `install-cli.md` and `install-skills.md` as reference snippets when needed

## Install baseline rules (symlink-based)

Run:
```bash
python3 agents/install-rules.py
```

This creates symlinks to:
- Antigravity IDE: `~/.antigravity/AGENTS.md`
- OpenCode: `~/.config/opencode/AGENTS.md`

## Behavior

- Each target is handled independently
- Missing destination directories are skipped
- Existing destination file/symlink is replaced with a symlink to this repo source file

## About `install-cli.md` and `install-skills.md`

Use them as snippet libraries:
- Review the commands
- Select what you need
- Run selected commands manually

## Conventions

- Keep rules minimal and focused
- Document all policies
- Test changes before committing
- Use consistent formatting
