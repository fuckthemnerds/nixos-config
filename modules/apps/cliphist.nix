{ config, lib, pkgs, ... }:
let
	cfg = config.apps.cliphist;
in
{
	options.apps.cliphist.enable = lib.mkEnableOption "clipboard history";

	config = lib.mkIf cfg.enable {
		systemd.user.services.cliphist = {
			wantedBy = [ "graphical-session.target" ];
			Unit = {
				Description = "Clipboard history daemon";
				After = [ "graphical-session.target" ];
			};
			Service = {
				ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
				Restart = "always";
			};
		};
	};
}