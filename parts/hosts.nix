{ self, inputs, lib, ... }:

let
	localLib = import ../lib.nix { inherit lib; };
in
{
	# Import all host definitions
	imports = localLib.importModules ../hosts;

	flake = {
		# Re-usable host builder
		lib.mkHost = { hostName, hostConfig ? {}, extraModules ? [] }:
		let
			inherit (self) globals gitRemoteUrl;
		in
		inputs.nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			specialArgs = {
				inherit inputs hostName;
				inherit (globals) userName stateVersion themeName;
				inherit gitRemoteUrl;
			};
			modules = [
				hostConfig
				../hosts/${hostName}/hardware.nix
				../system/zz_system_input.nix
				inputs.impermanence.nixosModules.impermanence
				inputs.sops-nix.nixosModules.sops
				inputs.home-manager.nixosModules.home-manager
				inputs.disko.nixosModules.disko
				inputs.nix-index-database.nixosModules.nix-index-database
				inputs.niri.nixosModules.niri
				../hosts/${hostName}/disko.nix
			] ++ extraModules;
		};
	};
}
