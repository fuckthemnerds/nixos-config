{
  config,
  userName,
  ...
}: {

  # ===========================================================================
  # Global Decryption Configurations
  # ===========================================================================
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;

    defaultSopsFormat = "yaml";

    # Turn off verification on rebuilds to prevent network lookups in offline modes.
    validateSopsFiles = false;

    age = {
      keyFile = "/persistent/var/lib/sops-nix/keys.txt";

      # Use host SSH private key as backup decryption mechanism.
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };

    # =========================================================================
    # Declarative System Secrets
    # =========================================================================
    secrets = {
      user_password_filip = {
        # Ensure password file is decrypted before systemd registers users.
        neededForUsers = true;
        
        # Read-only permission to user managers (root and group wheel).
        mode = "0440";
      };

      git_credentials = {
        owner = config.users.users."${userName}".name;

        path = "/home/${userName}/.config/git/credentials";
        
        # Restrictive user-only read permissions (0400).
        mode = "0400";
      };
    };
  };
}
