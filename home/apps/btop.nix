{ config, pkgs, ... }:

{
	programs.btop = {
		enable = true;
		settings = {
			color_theme = "oxocarbon";
			theme_background = true;
			truecolor = true;
			vim_keys = true;
			rounded_corners = false;
			graph_symbol = "braille";
			shown_boxes = "cpu mem net proc";
		};
	};
}
