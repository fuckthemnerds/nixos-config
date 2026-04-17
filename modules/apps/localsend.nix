{ config, lib, pkgs, globals, ... }:

let
	cfg = config.apps.localsend;
in
{
	options.apps.localsend.enable = lib.mkEnableOption "localsend";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			home.packages = [ pkgs.localsend ];
		};

		networking.firewall = {
			allowedTCPPorts = [ 53317 ];
			allowedUDPPorts = [ 53317 ];
		};
	};
}
