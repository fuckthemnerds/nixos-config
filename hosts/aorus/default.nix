{
  config,
  pkgs,
  ...
}: {
  boot.kernelParams = ["acpi_osi=Linux" "pci=noaer"];
  boot.kernelPackages = pkgs.linuxPackages_zen;

  environment.systemPackages = [
    pkgs.nvtopPackages.full
  ];

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:1:0:0";
  };
}