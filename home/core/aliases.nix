{
	# ── SHELL ABBREVIATIONS (FISH) ────────────────────────────────────────────────
	# Using 'abbr' so commands are expanded and visible before execution.
	programs.fish.shellAbbrs = {
		# --- Rebuild Commands (via nh) ---
		nrs   = "nh os switch --flake /persist";  # Switch generation
		nrb   = "nh os boot   --flake /persist";  # Set boot entry
		nrt   = "nh os test   --flake /persist";  # Temporary test

		# --- Maintenance & Flakes ---
		nfu   = "nix flake update /persist";      # Update all inputs
		nfc   = "nix flake check  /persist";      # Verify flake syntax
		ngc   = "nh clean all";                   # High-level GC
		cdnix = "cd /persist";                    # Jump to config

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
		# --- Modern Alternatives ---
		ls    = "eza --icons";
		ll    = "eza -lh --icons --grid --group-directories-first";
		la    = "eza -lah --icons --grid --group-directories-first";
		lt    = "eza --tree --icons";
		y     = "yazi";

		# --- System Utilities ---
		sudo  = "sudo --preserve-env=PATH,EDITOR,VISUAL env";
	};
}
