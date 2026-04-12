{ pkgs, ... }:

{
	services.displayManager.ly.enable = true;
	
	# Disable SSH agent auth and U2F for the TTY display manager
	security.pam.services.ly = {
		sshAgentAuth = false;
		u2fAuth = false;
	};
}
