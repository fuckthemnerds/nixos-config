{ self, ... }:

let
	# Load local identity if it exists (for private username setup)
	localIdentity = 
		if builtins.pathExists ../local/identity.nix 
		then import ../local/identity.nix 
		else {};
in
{
	flake = {
		# --- Global Variables ---
		globals = {
			# Use local override, otherwise default to generic
			userName     = localIdentity.userName or "dendritic";
			stateVersion = "25.11";
			themeName    = "main";

			# --- Git Workflow Configuration ---
			gitPlatform = "github";
			gitUser     = "my-user";
			gitRepo     = "nixos-config";
		};

		# Computed Global: Remote URL
		gitRemoteUrl =
		let
			g = self.globals;
		in
		if      g.gitPlatform == "github"   then "https://github.com/${g.gitUser}/${g.gitRepo}"
		else if g.gitPlatform == "gitlab"   then "https://gitlab.com/${g.gitUser}/${g.gitRepo}"
		else if g.gitPlatform == "codeberg" then "https://codeberg.org/${g.gitUser}/${g.gitRepo}"
		else builtins.throw "Unknown gitPlatform: ${g.gitPlatform} (use github/gitlab/codeberg)";
	};
}
