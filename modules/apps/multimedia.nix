{ config, lib, pkgs, globals, ... }:

let
	cfg = config.apps.multimedia;
in
{
	options.apps.multimedia.enable = lib.mkEnableOption "multimedia applications (imv, mpv, yt-music)";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			programs = {
				imv.enable = true;
				mpv.enable = true;
			};
			home.packages = [ pkgs.pear-desktop ];
		};
	};
}