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
    localConfig =
      if builtins.pathExists ./secrets/usercreds.nix
      then import ./secrets/usercreds.nix
      else {};

    globals = {
      stateVersion = "26.05";
      userName = localConfig.userName or "null_User";
      userEmail = localConfig.userEmail or "null_Email";
      themeName = localConfig.themeName or "null_Theme";
      gitPlatform = localConfig.gitPlatform or "null_Platform";
      gitUser = localConfig.gitUser or "null_User";
      gitRepo = localConfig.gitRepo or "null_Repo";
      device = localConfig.device or "null_Device";
      timeZone = localConfig.timeZone or "null_TimeZone";
    };

    mkHost = {
      hostName,
      system ? "x86_64-linux",
      hostConfig ? {},
      extraModules ? [],
    }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = let
          gitRemoteUrl =
            if (globals ? gitPlatform && globals.gitPlatform == "github")
            then "https://github.com/${globals.gitUser}/${globals.gitRepo}"
            else "";
        in {
          inherit inputs hostName gitRemoteUrl globals;
          inherit (globals) userName stateVersion;
        };
        modules =
          [
            {
              networking.hostName = hostName;
              system.stateVersion = globals.stateVersion;
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
        inherit globals;
        lib.mkHost = mkHost;

        nixosConfigurations = {
          aorus = mkHost {hostName = "aorus";};
          surface = mkHost {
            hostName = "surface";
            extraModules = [inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel];
          };
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