{ config, lib, pkgs, ... }:
let
	cfg = config.apps.cliphist;
in
{
	options.apps.cliphist.enable = lib.mkEnableOption "cliphist";

	config = lib.mkIf cfg.enable {
		systemd.user.services.cliphist = {
			wantedBy = [ "graphical-session.target" ];
			unitConfig = {
				Description = "Clipboard history daemon";
				After = [ "graphical-session.target" ];
			};
			serviceConfig = {
				ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
				Restart = "always";
			};
		};
	};
}