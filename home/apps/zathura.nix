{ config, pkgs, ... }:

let
	palette = config.theme.palette;
in
{
	# ── ZATHURA PDF VIEWER CONFIGURATION ──────────────────────────────────────────
	programs.zathura = {
		enable = true;

		options = {
			# --- General & Render ---
			font = "IBM Plex Sans 12";
			sandbox = "none";
			render-loading = false;

			# --- Appearance (Carbon Palette) ---
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

			# --- Dark-Mode Inversion ---
			recolor            = true;
			recolor-lightcolor = palette.background;
			recolor-darkcolor  = palette.textPrimary;
			recolor-keephue    = true;
		};

		# --- Mappings ---
		mappings = {
			J = "navigate next";
			K = "navigate previous";
			"<C-i>" = "recolor";
		};
	};
}
