{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [
		(modulesPath + "/installer/scan/not-detected.nix")
	] ++ (if builtins.pathExists ./hardware-stub.nix then [ ./hardware-stub.nix ] else [ ]);

	boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod" ];
	boot.kernelModules = [ "kvm-intel" ];

	swapDevices = [ ];
}