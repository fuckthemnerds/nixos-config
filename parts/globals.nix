{ self, ... }:

{
	flake = {
		globals = let
			# Try to load local overrides, fallback to defaults
			# NOTE: local/config.nix must be 'git add'ed (even if not committed) for Nix to see it.
			localPath = ../local/config.nix;
			local = if builtins.pathExists localPath then import localPath else {};
		in {
			userName     = local.userName     or "dendritic";
			stateVersion = local.stateVersion or "25.11";
			themeName    = local.themeName    or "main";

			gitPlatform  = local.gitPlatform  or "github";
			gitUser      = local.gitUser      or "placeholder";
			gitRepo      = local.gitRepo      or "nixos-config";

			# Centralized unfree software whitelist for the entire flake.
			unfreePackages = [
				"antigravity"
				"claude-code"
				"code-cursor"
				"nvidia-settings"
				"nvidia-x11"
				"teams-for-linux"
				"youtube-music"
			];
		};

		gitRemoteUrl = let
			g = self.globals;
		in
			if      g.gitPlatform == "github"   then "https://github.com/${g.gitUser}/${g.gitRepo}"
			else if g.gitPlatform == "gitlab"   then "https://gitlab.com/${g.gitUser}/${g.gitRepo}"
			else if g.gitPlatform == "codeberg" then "https://codeberg.org/${g.gitUser}/${g.gitRepo}"
			else builtins.throw "Unknown gitPlatform: ${g.gitPlatform} (use github/gitlab/codeberg)";
	};
}
