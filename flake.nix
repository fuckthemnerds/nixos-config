{
	description = "Refactored Impermanent Dual-Host NixOS Configuration";

	# ── INPUTS ────────────────────────────────────────────────────────────────────
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		flake-parts.url = "github:hercules-ci/flake-parts";
		
		# --- Hardware & Persistence ---
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";
		impermanence.url = "github:nix-community/impermanence";
		disko = {
			url = "github:nix-community/disko";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		
		# --- User Environment ---
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixvim = {
			url = "github:nix-community/nixvim";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# --- Secrets ---
		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# --- Tooling ---
		nix-index-database = {
			url = "github:nix-community/nix-index-database";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		niri.url = "github:sodiboo/niri-flake";
	};

	# ── OUTPUTS ───────────────────────────────────────────────────────────────────
	outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
		flake-parts.lib.mkFlake { inherit inputs; } {
			systems = [ "x86_64-linux" ];
			
			# Import decentralized flake parts
			imports = [
				./parts/globals.nix
				./parts/hosts.nix
			];

			perSystem = { config, self', inputs', pkgs, system, ... }: {
				# Standard pkgs with unfree allowed
				_module.args.pkgs = import nixpkgs {
					inherit system;
					config.allowUnfree = true;
				};
			};
		};
}
