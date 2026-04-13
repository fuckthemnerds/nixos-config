{ config, pkgs, userName, ... }:

{
	users = {
		mutableUsers = false;
		users.${userName} = {
			isNormalUser = true;
			description = "Primary User";
			hashedPasswordFile = config.sops.secrets."user_password_${userName}".path;
			extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
			shell = pkgs.fish;
		};
	};
}