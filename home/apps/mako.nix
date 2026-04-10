{ config, pkgs, ... }:

let
	palette = config.theme.palette;
in
{
	services.mako = {
		enable = true;
		settings = {
			font = "BlexMono Nerd Font 10";
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

			background-color = "${palette.background}f2";
			text-color = palette.textPrimary;
			border-color = palette.borderSubtle;
			progress-color = "over ${palette.interactive}";

			"urgency=low" = {
				border-color = palette.layer03;
				default-timeout = 3000;
			};
			"urgency=normal" = {
				border-color = palette.borderSubtle;
				default-timeout = 5000;
			};
			"urgency=critical" = {
				border-color = palette.supportError;
				background-color = "${palette.background}f2";
				text-color = palette.supportError;
				default-timeout = 0;
			};
		};
	};
}
