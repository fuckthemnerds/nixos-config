{ hostName, ... }:

{
	# ── GIT CONFIGURATION (HOME MANAGER) ──────────────────────────────────────────
	programs.git = {
		enable = true;
		
		# --- User Identity ---
		userEmail = "email@example.com";
		userName  = "username"; # Using hostName is also an option: hostName
		
		# --- Global Settings ---
		settings = {
			init.defaultBranch = "main";
			pull.rebase = true;
			core.editor = "nvim";
		};

		# --- Aesthetic & UI ---
		delta = {
			enable = true;
			options = {
				# Modern, blocky diffs
				navigate = true;
				light = false;
				side-by-side = true;
			};
		};
	};
}
