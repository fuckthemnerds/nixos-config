{ config, lib, pkgs, inputs, userName, hostName, stateVersion, themeName, gitRemoteUrl, ... }:

{
	imports = [ ];

	nix = {
		settings = {
			trusted-users = [ "root" userName ];
			allowed-users = [ "@wheel" ];
			auto-optimise-store = true; # Saves disk space by hardlinking identical files
		};

		# Pin registry and NIX_PATH to flake inputs for 'self-hosting' consistency
		registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
		nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
	};
	
	zramSwap.enable = true;

	# Pulls latest nixpkgs and rebuilds daily with jitter to avoid thundering herd
	system.autoUpgrade = {
		enable = true;
		flake = gitRemoteUrl;
		flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
		dates = "daily";
		randomizedDelaySec = "4h";
	};

	# Notification bridge for auto-upgrades
	systemd.services.nixos-upgrade = {
		preStart = ''
			USER_ID=$(${pkgs.coreutils}/bin/id -u ${userName})
			if [ -d /run/user/$USER_ID ]; then
				${pkgs.su}/bin/su ${userName} -c "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_ID/bus ${pkgs.libnotify}/bin/notify-send -u low 'NixOS' 'System upgrade starting...'"
			fi
		'';
		postStop = ''
			USER_ID=$(${pkgs.coreutils}/bin/id -u ${userName})
			if [ -d /run/user/$USER_ID ]; then
				${pkgs.su}/bin/su ${userName} -c "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_ID/bus ${pkgs.libnotify}/bin/notify-send 'NixOS' 'System upgrade finished'"
			fi
		'';
	};

	# Disable default command-not-found (using nix-index/comma instead)
	programs.command-not-found.enable = false;

	environment.sessionVariables = {
		NIXOS_OZONE_WL = "1";
	};

	home-manager = {
		useGlobalPkgs = true;
		useUserPackages = true;
		extraSpecialArgs = { inherit inputs userName stateVersion hostName themeName gitRemoteUrl; };
		sharedModules = [ inputs.nixvim.homeModules.nixvim ];

		users.${userName} = { pkgs, inputs, hostName, ... }: {
			home.stateVersion = stateVersion;
			home.username = userName;
			home.homeDirectory = lib.mkForce "/home/${userName}";

			imports = [
				../../home/home.nix   # Automatically imports apps, core, themes
			];
		};
	};
}
