{ config, lib, pkgs, globals, ... }:
let
	cfg = config.apps.mako;
in
{
	options.apps.mako.enable = lib.mkEnableOption "mako";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			services.mako = {
				enable = true;
				settings = {
					width = 350;
					height = 150;
					margin = "10";
					padding = "15";
					border-size = 2;
					border-radius = 0;
					icons = true;
					max-icon-size = 48;
					icon-location = "left";
					markup = true;
					actions = true;
					default-timeout = 5000;
					ignore-timeout = true;

					"urgency=low" = {
						default-timeout = 3000;
					};
					"urgency=normal" = {
						default-timeout = 5000;
					};
					"urgency=critical" = {
						default-timeout = 0;
					};
				};
			};
		};
	};
}