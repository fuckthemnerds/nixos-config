# Stub – replaced by nixos-generate-config during install.sh execution.
# UUIDs and exact subvol names will be overwritten. The structure must
# match the Btrfs layout created by install.sh.
{ config, lib, pkgs, modulesPath, ... }:

{
	imports = [ 
		(modulesPath + "/installer/scan/not-detected.nix") 
	] ++ (if builtins.pathExists ./hardware-stub.nix then [ ./hardware-stub.nix ] else [ ]);

	# Surface Pro (Intel) kernel modules
	boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "uas" "sd_mod" ];
	boot.kernelModules = [ "kvm-intel" ];

	# ── File systems ──────────────────────────────────────────────────────────────
	# Managed by Disko (see hosts/surface/disko.nix)

	swapDevices = [ ];
}
