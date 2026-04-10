{ pkgs, ... }:

{
	# Display Manager & Compositor Architecture
	services.displayManager.ly.enable = true;
	programs.niri.enable = true;
}
