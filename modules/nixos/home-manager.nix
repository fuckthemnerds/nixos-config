{
  lib,
  inputs,
  userName,
  hostName,
  stateVersion,
  myLib,
  ...
}: {

  # ===========================================================================
  # Home-Manager Engine Configuration
  # ===========================================================================
  home-manager = {
    # Use the system's global pkgs set directly, avoiding duplicate instantiation.
    useGlobalPkgs = true;

    # Install user packages directly to the system profile for consistency.
    useUserPackages = true;

    backupFileExtension = "backup";

    extraSpecialArgs = { inherit inputs userName stateVersion hostName myLib; };

    sharedModules = [];

    # =========================================================================
    # User Environment & Home Directory Settings
    # =========================================================================
    users.${userName} = {
      home.stateVersion = stateVersion;

      home.username = userName;

      # Force declarative home path instead of letting home-manager guess.
      home.homeDirectory = lib.mkForce "/home/${userName}";

      # Disable manual page generation to optimize overall rebuild speeds.
      manual.manpages.enable = false;
    };
  };
}
