{ self, inputs, ... }:

{
	flake.nixosConfigurations.surface = self.lib.mkHost {
		hostName = "surface";
		hostConfig = { ... }: {
		};
		extraModules = [
			inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
		];
	};
}
