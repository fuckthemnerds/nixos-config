{ config, lib, pkgs, globals, ... }:
let
	cfg = config.apps.zathura;
in
{
	options.apps.zathura.enable = lib.mkEnableOption "zathura document viewer";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			programs.zathura = {
				enable = true;

				options = {
					font = "IBM Plex Sans 12";
					sandbox = "none";
					render-loading = false;
					recolor = true;
					recolor-keephue = true;
				};

				mappings = {
					J = "navigate next";
					K = "navigate previous";
					"<C-i>" = "recolor";
				};
			};
		};
	};
}