{ self, inputs, ... }:

{
	flake.nixosConfigurations.aorus = self.lib.mkHost {
		hostName = "aorus";
		hostConfig = { pkgs, hostName, stateVersion, ... }: {

			# ── HOST CONFIGURATION: AORUS ─────────────────────────────────────────────────
			# Trace for user verification
			_module.args.swapStatus = builtins.trace "SWAP IS ENABLED ON AORUS (zram)" null;

			networking.hostName = hostName;
			boot.kernelPackages = pkgs.linuxPackages_zen;

			# --- Hardware Enablement (Nvidia/Intel) ---
			services.xserver.videoDrivers = [ "nvidia" ];
			hardware.nvidia = {
				modesetting.enable = true;
				open               = false;
				powerManagement.enable = true;

				# PCI Bus IDs (Verify with lspci)
				prime.intelBusId   = "PCI:0:2:0";
				prime.nvidiaBusId  = "PCI:1:0:0";
			};

			# --- System Initialization ---
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
