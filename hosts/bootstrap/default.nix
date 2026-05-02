{ config, lib, pkgs, ... }:

{
	apps.niri.enable = lib.mkForce false;
	apps.gui-apps.enable = lib.mkForce false;
	apps.waybar.enable = lib.mkForce false;
	apps.hypridle.enable = lib.mkForce false;
	apps.hyprlock.enable = lib.mkForce false;
	apps.zen.enable = lib.mkForce false;
	apps.foot.enable = lib.mkForce false;
	apps.mako.enable = lib.mkForce false;
	apps.fuzzel.enable = lib.mkForce false;
	apps.multimedia.enable = lib.mkForce false;
	apps.zathura.enable = lib.mkForce false;
	apps.keepassxc.enable = lib.mkForce false;
	apps.localsend.enable = lib.mkForce false;
	apps.cliphist.enable = lib.mkForce false;

	# Minimal services for a bootstrap environment
	services.openssh.enable = true;
	networking.networkmanager.enable = true;
}
