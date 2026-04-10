{ lib, themeName, ... }:

let
	# --- Palette Definitions ---
	palettes = {
		main = import ./palettes/_theme.nix;
	};
in
{
	# ── THEME PALETTE INFRASTRUCTURE ──────────────────────────────────────────────
	options.theme.palette = lib.mkOption {
		type = lib.types.attrsOf lib.types.str;
		default = palettes.${themeName};
	};
}
