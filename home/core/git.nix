{ hostName, ... }:

{
	programs.git = {
		enable = true;
		
		userEmail = "dendritic@users.noreply.github.com";
		userName  = "Dendritic Admin"; 
		
		settings = {
			init.defaultBranch = "main";
			pull.rebase = true;
			core.editor = "nvim";
		};

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
