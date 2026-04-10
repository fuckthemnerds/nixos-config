{ pkgs, ... }:

{
	services.displayManager.ly.enable = true;
	programs.niri.enable = true;

	# Disable SSH agent auth and U2F for the TTY display manager
	security.pam.services.ly = {
		enableSSHAgentAuth = false;
		u2fAuth = false;
	};
}
