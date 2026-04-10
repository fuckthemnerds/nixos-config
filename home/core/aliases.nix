{
	# Using 'abbr' so commands are expanded and visible before execution.
	programs.fish.shellAbbrs = {
		# Uses 'nh' for clean output and nvd diffs
		nrs   = "nh os switch";                  # Switch generation
		nrb   = "nh os boot";                    # Set boot entry
		nrt   = "nh os test";                    # Temporary test
		nrh   = "nh home switch";                # Update user env only

		# --- Maintenance & Flakes ---
		nfu   = "nix flake update";              # Update all inputs
		nfc   = "nix flake check";               # Verify flake syntax
		cdnix = "cd /persistent/etc/nixos";      # Jump to config

		# --- Git Workflow ---
		gst   = "git status";
		gd    = "git diff";
		ga    = "git add";
		gaa   = "git add -A";
		gc    = "git commit -m";
		gca   = "git commit --amend --no-edit";
		gp    = "git push";
		gpl   = "git pull";
		gl    = "git log --oneline --graph --decorate -20";
	};

	# ── SHELL ALIASES ─────────────────────────────────────────────────────────────
	programs.fish.shellAliases = {
		ls    = "eza --icons";
		ll    = "eza -lh --icons --grid --group-directories-first";
		la    = "eza -lah --icons --grid --group-directories-first";
		lt    = "eza --tree --icons";
		y     = "yazi";

		sudo  = "sudo --preserve-env=PATH,EDITOR,VISUAL env";
	};
}
