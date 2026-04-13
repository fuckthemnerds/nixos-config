{ config, lib, pkgs, ... }:
let
	cfg = config.apps.btop;
in
{
	options.apps.btop.enable = lib.mkEnableOption "btop system monitor";

	config = lib.mkIf cfg.enable {
		programs.btop = {
			enable = true;
			settings = {
				theme_background = true;
				truecolor = true;
				vim_keys = true;
				rounded_corners = false;
				graph_symbol = "braille";
				shown_boxes = "cpu mem net proc";
			};
		};
	};
}