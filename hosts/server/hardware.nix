# -----------------------------------------------------------------------------
#  HOST: server/hardware.nix
#  DESCRIPTION: Declarative hardware modules configuration stub for the server.
# -----------------------------------------------------------------------------
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Core hardware kernel drivers
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod"];
  boot.kernelModules = ["kvm-intel"];

  # Swap space configuration matching standard system partitions
  swapDevices = [{device = "/dev/disk/by-partlabel/disk-main-swap";}];
  boot.resumeDevice = "/dev/disk/by-partlabel/disk-main-swap";
}
