{ self, inputs, lib, ... }:

let
	localLib = import ../lib.nix { inherit lib; };
in
{
	imports = localLib.importModules ../hosts;

	flake = {
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
				{
					networking.hostName = hostName;
					system.stateVersion = globals.stateVersion;
				}

				hostConfig
				../hosts/${hostName}/hardware.nix
				../system/system.nix
				inputs.impermanence.nixosModules.impermanence
				inputs.sops-nix.nixosModules.sops
				inputs.home-manager.nixosModules.home-manager
				inputs.disko.nixosModules.disko
				inputs.nix-index-database.nixosModules.nix-index
				inputs.niri.nixosModules.niri
				inputs.determinate.nixosModules.default
				../hosts/${hostName}/disko.nix
			] ++ extraModules;
		};
	};
}
