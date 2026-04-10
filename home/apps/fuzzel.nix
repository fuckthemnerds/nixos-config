{ config, pkgs, ... }:

let
	palette = config.theme.palette;
	hex = s: builtins.substring 1 6 s;
	solid = s: "${hex s}ff";
	alpha = s: a: "${hex s}${a}";
in
{
	programs.fuzzel = {
		enable = true;
		settings = {
			main = {
				font = "BlexMono Nerd Font:size=11";
				dpi-aware = "yes";
				prompt = "> ";
				use-bold = "no";
				icons-enabled = "no";
				terminal = "foot -a '{cmd}' -T '{cmd}' -e {cmd}";
				list-executables-in-path = "no";
				lines = 15;
				width = 40;
				horizontal-pad = 20;
				vertical-pad = 8;
				inner-pad = 10;
				anchor = "center";
				match-mode = "fzf";
			};
			colors = {
				background = alpha palette.background "f2";
				text = solid palette.textPrimary;
				message = solid palette.textPrimary;
				prompt = solid palette.linkPrimary;
				placeholder = solid palette.layer03;
				input = solid palette.textPrimary;
				match = solid palette.supportSuccess;
				selection = solid palette.focus;
				selection-text = solid palette.background;
				selection-match = solid palette.syntaxControl;
				counter = solid palette.layer03;
				border = solid palette.borderSubtle;
			};
			border = {
				width = 1;
				radius = 0;
			};
		};
	};
}
