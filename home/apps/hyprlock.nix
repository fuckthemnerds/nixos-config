{ config, pkgs, ... }:

let
	palette = config.theme.palette;
	hex = s: builtins.substring 1 6 s;
in
{
	programs.hyprlock = {
		enable = true;
		settings = {
			general = {
				disable_loading_bar = true;
				hide_cursor = true;
				grace = 0;
				no_fade_in = true;
			};
			background = [
				{
					monitor = "";
					color = "rgb(${hex palette.layer01})";
				}
			];
			input-field = [
				{
					monitor = "";
					size = "272, 56";
					outline_thickness = 8;
					dots_size = 0.25;
					dots_spacing = 0.2;
					dots_center = true;
					outer_color = "rgb(${hex palette.borderSubtle})";
					inner_color = "rgb(${hex palette.background})";
					font_color = "rgb(${hex palette.textPrimary})";
					fade_on_empty = false;
					placeholder_text = "password";
					fail_color = "rgb(${hex palette.supportError})";
					fail_text = "$FAIL ($ATTEMPTS)";
					fail_transition = 0;
					check_color = "rgb(${hex palette.interactive})";
					capslock_color = "rgb(${hex palette.supportWarning})";
					rounding = 0;
					font_family = "BlexMono Nerd Font";
					position = "0, 0";
					halign = "center";
					valign = "center";
				}
			];
		};
	};
}
