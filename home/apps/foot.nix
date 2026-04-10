{ config, pkgs, ... }:

let
	palette = config.theme.palette;
	hex = s: builtins.substring 1 6 s;
in
{
	programs.foot = {
		enable = true;
		server.enable = true;

		settings = {
			main = {
				font = "BlexMono Nerd Font:size=11";
				dpi-aware = "yes";
			};
			cursor = {
				style = "block";
				blink = "yes";
			};

			colors-dark = {
				alpha = "1.0";
				background = hex palette.background;
				foreground = hex palette.textPrimary;

				cursor = "${hex palette.background} ${hex palette.focus}";
				selection-foreground = hex palette.background;
				selection-background = hex palette.interactive;
				urls = hex palette.linkPrimary;

				regular0 = hex palette.layer01;
				regular1 = hex palette.supportError;
				regular2 = hex palette.supportSuccess;
				regular3 = hex palette.supportWarning;
				regular4 = hex palette.interactive;
				regular5 = hex palette.syntaxControl;
				regular6 = hex palette.syntaxAttribute;
				regular7 = hex palette.textPrimary;

				bright0 = hex palette.layer02;
				bright1 = hex palette.textError;
				bright2 = hex palette.syntaxNumber;
				bright3 = hex palette.syntaxFunction;
				bright4 = hex palette.linkPrimary;
				bright5 = hex palette.syntaxControl;
				bright6 = hex palette.syntaxTag;
				bright7 = hex palette.focus;
			};
		};
	};
}
