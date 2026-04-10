{ config, inputs, userName, hostName, stateVersion, themeName, gitRemoteUrl, ... }:

{
	# ── OS-LEVEL SYSTEM CONFIGURATION (NixOS) ─────────────────────────────────────
	# Handles kernels, bootloaders, and hardware. Applies globally.
	imports = [ ];

	# --- Nix Settings ---
	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			auto-optimise-store = true; # Deduplicate files to save disk space
			warn-dirty = false;
		};
		registry.nixpkgs.flake = inputs.nixpkgs;
		nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
	};

	# --- App Discovery & Execution ---
	# nix-index-database module (from flake) provides pre-built index;
	# no need to run nix-index manually. Enables Fish integration automatically.

	# --- System Maintenance (via nh) ---
	programs.nh = {
		enable = true;
		clean.enable = true;
		clean.extraArgs = "--keep-since 7d --keep 3";
		flake = "/persistent/etc/nixos";
	};

	# Disable default command-not-found (using nix-index/comma instead)
	programs.command-not-found.enable = false;

	# --- Environment ---
	environment.sessionVariables = {
		NIXOS_OZONE_WL = "1";
	};

	# ── USER-LEVEL CONFIGURATION (Home Manager) ───────────────────────────────────
	# Handles dotfiles and app settings. Logically separated from system layer.
	home-manager = {
		useGlobalPkgs = true;
		useUserPackages = true;
		extraSpecialArgs = { inherit inputs userName stateVersion hostName themeName gitRemoteUrl; };
		sharedModules = [ inputs.nixvim.homeModules.nixvim ];

		users.${userName} = { pkgs, inputs, hostName, ... }: {
			home.stateVersion = stateVersion;
			home.username = userName;
			home.homeDirectory = "/home/${userName}";

			# --- Module Discovery ---
			imports = [
				../home/zz_home_input.nix   # Automatically imports apps, core, themes
			];
		};
	};
}
