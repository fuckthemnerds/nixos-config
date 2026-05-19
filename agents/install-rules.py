#!/usr/bin/env python3
"""
Install agent rules to supported agent config directories.
Creates symlinks from this repository to agent homes.

Supported agents:
- Antigravity IDE
- OpenCode
"""

import os
import sys
from pathlib import Path

# Define targets: (agent_name, env_var, default_path, filename)
TARGETS = [
    ("Antigravity IDE", "ANTIGRAVITY_HOME", "~/.antigravity", "AGENTS.md"),
    ("OpenCode", "XDG_CONFIG_HOME", "~/.config/opencode", "AGENTS.md"),
]

def get_target_path(env_var, default_path):
    """Get the target directory path."""
    if env_var:
        path = os.environ.get(env_var, default_path)
    else:
        path = default_path
    return Path(path).expanduser()

def install_symlink(source, target_dir, target_filename):
    """Create a symlink from source to target."""
    target_path = target_dir / target_filename
    
    # Create directory if it doesn't exist
    target_dir.mkdir(parents=True, exist_ok=True)
    
    # Remove existing file/symlink
    if target_path.exists() or target_path.is_symlink():
        target_path.unlink()
    
    # Create symlink
    target_path.symlink_to(source)
    return True

def main():
    """Install agent rules."""
    # Get the source file
    script_dir = Path(__file__).parent
    source_file = (script_dir / "AGENTS.md").resolve()
    
    if not source_file.exists():
        print(f"Error: {source_file} not found")
        sys.exit(1)
    
    print(f"Installing agent rules from: {source_file}")
    print()
    
    success_count = 0
    skip_count = 0
    
    for agent_name, env_var, default_path, filename in TARGETS:
        target_dir = get_target_path(env_var, default_path)
        
        # Check if target directory exists
        if not target_dir.exists():
            print(f"⊘ {agent_name:20} - Directory not found: {target_dir}")
            skip_count += 1
            continue
        
        try:
            install_symlink(source_file, target_dir, filename)
            print(f"✓ {agent_name:20} - Installed to {target_dir / filename}")
            success_count += 1
        except Exception as e:
            print(f"✗ {agent_name:20} - Error: {e}")
    
    print()
    print(f"Summary: {success_count} installed, {skip_count} skipped")
    
    if success_count > 0:
        print("\n✓ Agent rules installed successfully!")
        sys.exit(0)
    else:
        print("\n⚠ No agent directories found. Install Antigravity IDE or OpenCode first.")
        sys.exit(1)

if __name__ == "__main__":
    main()
