{ config, userName, ... }:

{
	sops = {
		defaultSopsFile = ../../secrets/secrets.yaml;
		defaultSopsFormat = "yaml";
		validateSopsFiles = false;

		age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

		secrets."user_password_${userName}" = {
			neededForUsers = true;
			mode = "0440";
		};
	};
}