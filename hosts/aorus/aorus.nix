{ self, inputs, ... }:

{
	flake.nixosConfigurations.aorus = self.lib.mkHost {
		hostName = "aorus";
		hostConfig = { config, pkgs, hostName, stateVersion, ... }: {

			networking.hostName = hostName;
			boot.kernelPackages = pkgs.linuxPackages_zen;

			services.xserver.videoDrivers = [ "nvidia" ];
			hardware.nvidia = {
				modesetting.enable = true;
				open               = false;
				powerManagement.enable = true;
				package = config.boot.kernelPackages.nvidiaPackages.stable;

				# PCI Bus IDs (Verify with lspci)
				prime.intelBusId   = "PCI:0:2:0";
				prime.nvidiaBusId  = "PCI:1:0:0";
			};

			system.stateVersion = stateVersion;
		};
		extraModules = [
			inputs.nixos-hardware.nixosModules.common-cpu-intel
			inputs.nixos-hardware.nixosModules.common-pc-laptop
			inputs.nixos-hardware.nixosModules.common-pc-ssd
			inputs.nixos-hardware.nixosModules.common-gpu-nvidia-sync
		];
	};
}
