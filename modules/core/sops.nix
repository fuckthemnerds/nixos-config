{ config, userName, ... }:

{
	sops = {
		defaultSopsFile = ../../secrets/secrets.yaml;
		defaultSopsFormat = "yaml";
		validateSopsFiles = false;

		age.keyFile = "/persistent/var/lib/sops-nix/keys.txt";
		age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

		secrets."user_password_${userName}" = {
			neededForUsers = true;
			mode = "0440";
		};

		secrets.git_credentials = {
			owner = config.users.users."${userName}".name;
			path = "/home/${userName}/.config/git/credentials";
			mode = "0400";
		};
	};
}