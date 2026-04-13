{
  description = "Refactored Impermanent Dual-Host NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      flake = {
        globals = {
          stateVersion = "26.05";
        } // (if builtins.pathExists ./local/config.nix
             then import ./local/config.nix
             else {
               userName = "__CHANGE_ME__";
               userEmail = "__CHANGE_ME__";
               gitPlatform = "__CHANGE_ME__";
               gitUser = "__CHANGE_ME__";
               gitRepo = "__CHANGE_ME__";
             });

        lib.mkHost = { hostName, hostConfig ? {}, extraModules ? [] }:
          let
            inherit (self) globals;
          in
          inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = let
              gitRemoteUrl = if globals.gitPlatform == "github" then "https://github.com/${globals.gitUser}/${globals.gitRepo}" else "";
            in {
              inherit inputs hostName gitRemoteUrl globals;
              inherit (globals) userName stateVersion;
            };
            modules = [
              {
                networking.hostName = hostName;
                system.stateVersion = globals.stateVersion;
                nixpkgs.config.allowUnfree = true;
              }

              ] ++ ((import ./imports.nix { inherit (inputs.nixpkgs) lib; }).importModules ./modules) ++ [

              ./hosts/${hostName}/default.nix
              ./hosts/${hostName}/hardware.nix
              ./hosts/${hostName}/disko.nix

              inputs.impermanence.nixosModules.impermanence
              inputs.sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              inputs.disko.nixosModules.disko
              inputs.determinate.nixosModules.default
              inputs.stylix.nixosModules.stylix

              hostConfig
            ] ++ extraModules;
          };

        nixosConfigurations = {
          aorus = self.lib.mkHost { hostName = "aorus"; };
          surface = self.lib.mkHost { hostName = "surface"; };
        };
      };

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