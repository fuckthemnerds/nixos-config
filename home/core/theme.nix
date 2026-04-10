{ config, pkgs, ... }:

let
	palette = config.theme.palette;
in
{
	# ── USER INTERFACE THEMING ────────────────────────────────────────────────────
	# Unified visual style for GTK, QT, Icons, and Cursors.

	# --- Icons & Cursor ---
	home.packages = with pkgs; [
		tela-icon-theme
		google-cursor
	];

	home.pointerCursor = {
		package = pkgs.google-cursor;
		name    = "GoogleDot-Blue";
		size    = 24;
		gtk.enable = true;
		x11.enable = true;
	};

	# --- GTK Configuration ---
	gtk = {
		enable = true;
		theme  = {
			name    = "adw-gtk3-dark";
			package = pkgs.adw-gtk3;
		};
		iconTheme = {
			name    = "Tela-dark";
			package = pkgs.tela-icon-theme;
		};
		font = {
			name = "IBM Plex Sans";
			size = 11;
		};

		# Force dark preference
		gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
		gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;

		# Silence legacy theme warning globally
		gtk4.theme = null;

		# --- Strict Blocky Aesthetic (CSS) ---
		gtk3.extraCss = ''
		/* Reset Global Border Radius */
		* {
			border-radius: 0 !important;
			box-shadow: none !important;
		}

		/* Palette Injection */
		window, dialog {
			background-color: ${palette.background};
			color: ${palette.textPrimary};
		}

		headerbar {
			background-color: ${palette.layer01};
			border-bottom: 1px solid ${palette.layer02};
		}

		button {
			background-image: none;
			background-color: ${palette.layer02};
			border-radius: 0;
		}

		button:hover { background-color: ${palette.interactive}; }

		selection {
			background-color: ${palette.interactive};
			color: ${palette.background};
		}
		'';
	};

	# --- Qt Configuration ---
	qt = {
		enable = true;
		platformTheme.name = "gtk";
		style.name = "adwaita-dark";
	};

	# --- Dconf Settings ---
	dconf.settings = {
		"org/gnome/desktop/interface" = {
			color-scheme = "prefer-dark";
			gtk-theme    = "adw-gtk3-dark";
			icon-theme   = "Tela-dark";
			cursor-theme = "GoogleDot-Blue";
		};
	};
}
