{ lib, themeName, ... }:

let
	palettes = {
		main = import ./palettes/_carbon.nix;
	};
in
{
	options.theme.palette = lib.mkOption {
		type = lib.types.attrsOf lib.types.str;
		default = palettes.${themeName};
	};
}
