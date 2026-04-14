{ config, lib, pkgs, globals, ... }:
let
	cfg = config.apps.ai;
in
{
	options.apps.ai.enable = lib.mkEnableOption "ai";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			home.packages = with pkgs; [
				code-cursor
				claude-code
				antigravity
			];
		};
	};
}