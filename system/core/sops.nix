{ config, userName, ... }:

{
	sops = {
		defaultSopsFile = "/persistent/etc/nixos/secrets/secrets.yaml";
		defaultSopsFormat = "yaml";
		validateSopsFiles = false; # File is generated at install time

		age.sshKeyPaths = [ "/persistent/etc/ssh/ssh_host_ed25519_key" ];

		secrets."user_password_${userName}" = {
			neededForUsers = true;
			mode = "0440"; # Restrict to owner/group read-only
		};
	};
}
