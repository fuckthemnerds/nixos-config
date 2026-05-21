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
  # Disable visual splash loader on server
  boot.plymouth.enable = false;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 1; # Retain only current generation for server
    consoleMode = "auto";
    editor = false; # Secure boot control
  };

  # Zero timeout for headless reboots
  boot.loader.timeout = 0;

  # ===========================================================================
  # Kernel Parameters
  # ===========================================================================
  # Server-specific parameters: drops into shell if critical mount fails
  boot.kernelParams = [
    "boot.shell_on_fail"
  ];
}
