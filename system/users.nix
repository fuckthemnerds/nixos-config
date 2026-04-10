{ config, pkgs, userName, ... }:

{
	# ── USER ACCOUNT CONFIGURATION ────────────────────────────────────────────────

	# --- Shell & Permissions ---
	programs.fish.enable = true;

	# --- Identity ---
	users.mutableUsers = false;
	users.users.${userName} = {
		isNormalUser = true;
		description = "Primary User";
		hashedPasswordFile = config.sops.secrets."user_password_${userName}".path;
		extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
		shell = pkgs.fish;
	};
}
