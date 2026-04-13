{ config, lib, pkgs, globals, ... }:

let
	cfg = config.apps.gui-apps;
in
{
	options.apps.gui-apps.enable = lib.mkEnableOption "graphical productivity apps (librewolf, keepassxc, teams)";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			programs.librewolf = {
				enable = true;
				settings = {
					"webgl.disabled" = false;
					"privacy.resistFingerprinting" = false;
				};
			};
			home.packages = with pkgs; [
				keepassxc
				teams-for-linux
			];
		};
	};
}