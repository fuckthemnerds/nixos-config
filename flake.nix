{
	description = "Refactored Impermanent Dual-Host NixOS Configuration";

	inputs = {
		nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
		flake-parts.url = "github:hercules-ci/flake-parts";
		
		# Hardware & Persistence
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";
		impermanence.url = "github:nix-community/impermanence";
		disko = {
			url = "github:nix-community/disko";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixvim = {
			url = "github:nix-community/nixvim";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		niri.url = "github:sodiboo/niri-flake";
		determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
	};

	outputs = inputs@{ self, flake-parts, ... }:
		flake-parts.lib.mkFlake { inherit inputs; } {
			systems = [ "x86_64-linux" ];
			
			imports = [
				./parts/globals.nix
				./parts/hosts.nix
			];

			perSystem = { self', pkgs, ... }: {
				apps.default = self'.apps.install;
				apps.install = {
					type = "app";
					program = pkgs.lib.getExe (pkgs.writeShellScriptBin "install" ''
						export PATH="${pkgs.lib.makeBinPath [ pkgs.git ]}:$PATH"
						exec "${self}/install.sh" "$@"
					'');
				};
			};
		};
}
