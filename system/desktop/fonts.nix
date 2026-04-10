{ pkgs, ... }:

{
	fonts.packages = with pkgs; [
		nerd-fonts.jetbrains-mono
		nerd-fonts.blex-mono
		ibm-plex
		noto-fonts-color-emoji
	];

	# Font rendering — no hinting/antialiasing (bitmap-clean look)
	fonts.fontconfig = {
		enable = true;
		defaultFonts = {
			monospace = [ "BlexMono Nerd Font" "JetBrainsMono Nerd Font" ];
			sansSerif = [ "IBM Plex Sans" ];
			serif = [ "IBM Plex Serif" ];
			emoji = [ "Noto Color Emoji" ];
		};
		hinting = {
			enable = false;
			style = "none";
		};
		antialias = false;
	};
}
