{ config, pkgs, ... }:

let
	palette = config.theme.palette;
	# Helper to remove '#' for foot config
	hex = s: builtins.substring 1 6 s;
in
{
	# ── FOOT TERMINAL CONFIGURATION ───────────────────────────────────────────────
	programs.foot = {
		enable = true;
		server.enable = true;

		settings = {
			# --- General & Cursor ---
			main = {
				font = "BlexMono Nerd Font:size=11";
				dpi-aware = "yes";
				pad = "12x12";
			};
			cursor = {
				style = "block";
				blink = "yes";
			};

			# --- Appearance (Carbon Palette) ---
			colors = {
				alpha = "1.0";
				background = hex palette.background;
				foreground = hex palette.textPrimary;

				cursor = "${hex palette.background} ${hex palette.focus}";
				selection-foreground = hex palette.background;
				selection-background = hex palette.interactive;
				urls = hex palette.linkPrimary;

				# Normal colors (color0-color7)
				regular0 = hex palette.layer01;      # gray90
				regular1 = hex palette.supportError;  # red50
				regular2 = hex palette.supportSuccess; # green40
				regular3 = hex palette.supportWarning; # yellow30
				regular4 = hex palette.interactive;    # blue50
				regular5 = hex palette.syntaxControl;  # purple40
				regular6 = hex palette.syntaxAttribute; # cyan40
				regular7 = hex palette.textPrimary;    # gray10

				# Bright colors (color8-color15)
				bright0 = hex palette.layer02;       # gray80
				bright1 = hex palette.textError;      # red40
				bright2 = hex palette.syntaxNumber;   # green30
				bright3 = hex palette.syntaxFunction; # yellow30
				bright4 = hex palette.linkPrimary;    # blue40
				bright5 = hex palette.syntaxControl;  # purple40
				bright6 = hex palette.syntaxTag;       # teal30
				bright7 = hex palette.focus;          # white
			};
		};
	};
}
