{ pkgs, ... }:
{
  # Toggles features from modules/ (Enabled by default in defaults.nix)

  # Host specific overrides
  boot.kernelPackages = pkgs.linuxPackages_zen;

  environment.systemPackages = [
    pkgs.nvtopPackages.full
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true;
    package = pkgs.linuxPackages_zen.nvidiaPackages.stable;

    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:1:0:0";
  };
}