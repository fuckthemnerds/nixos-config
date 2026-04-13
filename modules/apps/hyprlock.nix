{ config, lib, pkgs, globals, ... }:

let
	cfg = config.apps.hyprlock;
	colors = config.lib.stylix.colors;
in
{
	options.apps.hyprlock.enable = lib.mkEnableOption "hyprlock screen locker";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			stylix.targets.hyprlock.enable = false;
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
							color = "rgb(${colors.base01})";
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
							outer_color = "rgb(${colors.base0D})";
							inner_color = "rgb(${colors.base01})";
							font_color = "rgb(${colors.base05})";
							fade_on_empty = true;
							placeholder_text = "<i>Password...</i>";
							hide_input = false;
							position = "0, -20";
							halign = "center";
							valign = "center";
						}
					];

					label = [
						{
							text = "$TIME";
							color = "rgb(${colors.base05})";
							font_size = 64;
							font_family = config.stylix.fonts.monospace.name;
							position = "0, 80";
							halign = "center";
							valign = "center";
						}
					];
				};
			};
		};
	};
}