{ self, inputs, ... }:

{
	flake.nixosConfigurations.surface = self.lib.mkHost {
		hostName = "surface";
		hostConfig = { hostName, stateVersion, ... }: {

			# ── HOST CONFIGURATION: SURFACE ───────────────────────────────────────────────
			networking.hostName = hostName;

			# NOTE: Kernel and drivers are now managed by nixos-hardware

			# --- System Initialization ---
			system.stateVersion = stateVersion;
		};
		extraModules = [
			inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
		];
	};
}
