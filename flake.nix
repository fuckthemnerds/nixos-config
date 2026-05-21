{
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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    otter-launcher = {
      url = "github:kuokuo123/otter-launcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium-browser.url = "github:schembriaiden/helium-browser-nix-flake";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    ytm-player = {
      url = "github:peternaame-boop/ytm-player";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }: let
    myVars = import ./vars {inherit (inputs.nixpkgs) lib;};
    myLib = import ./lib {inherit (inputs.nixpkgs) lib;};
    extendedLib = inputs.nixpkgs.lib.extend (self: super: myLib);

    mkHost = {
      hostName,
      system ? "x86_64-linux",
      hostConfig ? {},
      extraModules ? [],
    }:
      extendedLib.nixosSystem {
        inherit system;
        specialArgs = let
          # TODO: switch to FOSS git host
          gitRemoteUrl =
            if (myVars ? gitPlatform && myVars.gitPlatform == "github")
            then "https://github.com/${myVars.gitUser}/${myVars.gitRepo}"
            else "";
        in {
          inherit inputs hostName gitRemoteUrl;
          globals = myVars;
          inherit (myVars) userName stateVersion;
          myLib = extendedLib;
        };
        modules =
          [
            {
              networking.hostName = hostName;
              system.stateVersion = myVars.stateVersion;
              nixpkgs.config.allowUnfree = true;
            }

            ./modules/default.nix

            ./hosts/${hostName}/default.nix
            ./hosts/${hostName}/hardware.nix
            ./hosts/${hostName}/disko.nix

            inputs.impermanence.nixosModules.impermanence
            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.home-manager
            inputs.disko.nixosModules.disko
            inputs.stylix.nixosModules.stylix

            hostConfig
          ]
          ++ extraModules;
      };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      flake = {
        globals = myVars;
        lib = extendedLib // {inherit mkHost;};

        nixosConfigurations = {
          aorus = mkHost {hostName = "aorus";};

          surface = mkHost {
            hostName = "surface";
            extraModules = [inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel];
          };

          server = mkHost {hostName = "server";};
        };
      };

      perSystem = {
        self',
        pkgs,
        ...
      }: {
        formatter = pkgs.alejandra;

        apps.default = self'.apps.install;
        apps.install = {
          type = "app";
          program = pkgs.lib.getExe (pkgs.writeShellScriptBin "install" ''
            export PATH="${pkgs.lib.makeBinPath [pkgs.git]}:$PATH"
            exec "${self}/install.sh" "$@"
          '');
        };
      };
    };
}

