{ hostName, ... }:

{
	programs.git = {
		enable = true;

		settings = {
			user.email = "dendritic@users.noreply.github.com";
			user.name  = "Dendritic Admin";
			init.defaultBranch = "main";
			pull.rebase = true;
			core.editor = "nvim";
		};
	};

	programs.delta = {
		enable = true;
		enableGitIntegration = true;
		options = {
			# Modern, blocky diffs
			navigate = true;
			light = false;
			side-by-side = true;
		};
	};
}
