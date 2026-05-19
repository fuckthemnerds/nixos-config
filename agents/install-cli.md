# CLI Installation Snippets

Curated commands for common CLI tool installations and updates.

## Development Tools

### Just (task runner)
```bash
nix shell nixpkgs#just nixpkgs#nushell
```

### Nix tools
```bash
nix shell nixpkgs#nix-output-monitor
nix shell nixpkgs#nixfmt
nix shell nixpkgs#sops
```

### Git tools
```bash
nix shell nixpkgs#git
nix shell nixpkgs#git-crypt
```

### Editors
```bash
nix shell nixpkgs#neovim
nix shell nixpkgs#helix
```

## System Tools

### Monitoring
```bash
nix shell nixpkgs#htop
nix shell nixpkgs#btop
```

### File management
```bash
nix shell nixpkgs#ripgrep
nix shell nixpkgs#fd
```

### Terminal utilities
```bash
nix shell nixpkgs#fzf
nix shell nixpkgs#bat
```

## Usage

1. Review the command
2. Copy and run in your terminal
3. Tools will be available in the nix shell
4. Exit with `exit` or Ctrl+D
