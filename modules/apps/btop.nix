{ config, lib, pkgs, globals, ... }:
let
	cfg = config.apps.btop;
in
{
	options.apps.btop.enable = lib.mkEnableOption "btop";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
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
	};
}