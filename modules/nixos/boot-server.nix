# -----------------------------------------------------------------------------
#  MODULE: boot-server.nix
#  DESCRIPTION: Boot settings optimized for headless server machines.
#  This module inherits core options, disables graphical splashes for headless
#  operation, speeds up reboot times, and sets up debugging features.
# -----------------------------------------------------------------------------
{
  config,
  lib,
  ...
}: {
  imports = [
    ./boot-base.nix # Inherit common boot settings
  ];

  # Disable visual splash loader on server
  boot.plymouth.enable = false;

  # Fast, headless systemd-boot setup
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 1; # Retain only current generation for server
    consoleMode = "auto";
    editor = false; # Secure boot control
  };

  # Zero timeout for headless reboots
  boot.loader.timeout = 0;

  # Server-specific parameters: drops into shell if critical mount fails
  boot.kernelParams = [
    "boot.shell_on_fail"
  ];
}
