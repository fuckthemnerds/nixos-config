{ config, lib, pkgs, globals, ... }:
let
	cfg = config.apps.yazi;
in
{
	options.apps.yazi.enable = lib.mkEnableOption "yazi";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			programs.yazi = {
				enable = true;
				enableFishIntegration = true;
				settings = {
					manager = {
						show_hidden = true;
						sort_by = "natural";
					};
				};
			};
		};
	};
}