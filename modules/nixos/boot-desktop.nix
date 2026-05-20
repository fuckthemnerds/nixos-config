# -----------------------------------------------------------------------------
#  MODULE: boot-desktop.nix
#  DESCRIPTION: Boot settings optimized for desktop machines.
#  This module imports the base configuration and enables graphical boot (Plymouth)
#  along with interactive systemd-boot bootloader menus.
# -----------------------------------------------------------------------------
{
  config,
  lib,
  ...
}: {
  imports = [
    ./boot-base.nix # Inherit common boot settings
  ];

  # Graphical boot splash for desktop machines
  boot.plymouth.enable = true;

  # Systemd-boot configuration for interactive desktop boot
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5; # Limit generations to conserve space
    consoleMode = "auto";
    editor = false; # Disable loader editor for security
  };

  # Allow 5 seconds for user boot choice selection
  boot.loader.timeout = 5;

  # Desktop-specific kernel parameters for silent visual boot
  boot.kernelParams = [
    "quiet"
    "splash"
  ];
}
