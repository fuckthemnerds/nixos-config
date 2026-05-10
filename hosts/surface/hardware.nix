{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ]
    ++ (
      if builtins.pathExists ./hardware-stub.nix
      then [./hardware-stub.nix]
      else []
    );

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "uas" "sd_mod"];
  boot.kernelModules = ["kvm-intel"];
  boot.kernelParams = ["mem_sleep_default=deep"];

  swapDevices = [{device = "/dev/disk/by-partlabel/disk-main-swap";}];
  boot.resumeDevice = "/dev/disk/by-partlabel/disk-main-swap";
}