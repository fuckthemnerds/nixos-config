{ config, lib, pkgs, globals, ... }:
let
	cfg = config.apps.cliphist;
in
{
	options.apps.cliphist.enable = lib.mkEnableOption "cliphist";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			home.packages = [ pkgs.cliphist ];

			systemd.user.services.cliphist = {
				Unit = {
					Description = "Clipboard history daemon";
					After = [ "graphical-session.target" ];
					PartOf = [ "graphical-session.target" ];
				};
				Service = {
					ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
					Restart = "always";
				};
				Install = {
					WantedBy = [ "graphical-session.target" ];
				};
			};
		};
	};
}