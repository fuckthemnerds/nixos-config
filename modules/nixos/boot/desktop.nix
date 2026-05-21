{
  config,
  lib,
  ...
}: {
  imports = [
    ./base.nix
  ];

  # ===========================================================================
  # Bootloader Configuration
  # ===========================================================================
  boot.plymouth.enable = true;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5; # Limit generations to conserve space
    consoleMode = "auto";
    editor = false; # Disable loader editor for security
  };

  # Allow 5 seconds for user boot choice selection
  boot.loader.timeout = 5;

  # ===========================================================================
  # Kernel Parameters
  # ===========================================================================
  # Desktop-specific kernel parameters for silent visual boot
  boot.kernelParams = [
    "quiet"
    "splash"
  ];
}
