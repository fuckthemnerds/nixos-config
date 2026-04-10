{ hostName, ... }:

{
	# ── GIT CONFIGURATION (HOME MANAGER) ──────────────────────────────────────────
	programs.git = {
		enable = true;
		
		# --- User Identity ---
		userEmail = "dendritic@users.noreply.github.com";
		userName  = "Dendritic Admin"; 
		
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
