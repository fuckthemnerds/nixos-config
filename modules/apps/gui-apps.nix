{ config, lib, pkgs, globals, ... }:

let
	cfg = config.apps.gui-apps;
in
{
	options.apps.gui-apps.enable = lib.mkEnableOption "gui-apps";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {

			home.packages = with pkgs; [
				teams-for-linux
			];
		};
	};
}