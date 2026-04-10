{ config, userName, ... }:

{
	# ── SECRETS MANAGEMENT (SOPS-Nix) ─────────────────────────────────────────────
	sops = {
		defaultSopsFile = "/persistent/etc/nixos/secrets/secrets.yaml";
		defaultSopsFormat = "yaml";
		validateSopsFiles = false; # File is generated at install time

		# --- Keys & Paths ---
		# Location of host keys used for decryption
		age.sshKeyPaths = [ "/persistent/etc/ssh/ssh_host_ed25519_key" ];

		# --- Secrets ---
		secrets."user_password_${userName}" = {
			neededForUsers = true;
		};
	};
}
