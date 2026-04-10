{ config, pkgs, ... }:

let
	palette = config.theme.palette;
in
{
	programs.zathura = {
		enable = true;

		options = {
			font = "IBM Plex Sans 12";
			sandbox = "none";
			render-loading = false;

			default-bg             = palette.background;
			default-fg             = palette.textPrimary;
			statusbar-bg           = palette.layer01;
			statusbar-fg           = palette.textSecondary;
			inputbar-bg            = palette.layer01;
			inputbar-fg            = palette.textPrimary;
			notification-bg        = palette.layer01;
			notification-fg        = palette.textPrimary;
			notification-error-bg  = palette.layer01;
			notification-error-fg  = palette.textError;
			notification-warning-bg = palette.layer01;
			notification-warning-fg = palette.supportWarning;
			highlight-color        = palette.supportError;
			highlight-active-color = palette.supportSuccess;

			recolor            = true;
			recolor-lightcolor = palette.background;
			recolor-darkcolor  = palette.textPrimary;
			recolor-keephue    = true;
		};

		mappings = {
			J = "navigate next";
			K = "navigate previous";
			"<C-i>" = "recolor";
		};
	};
}
