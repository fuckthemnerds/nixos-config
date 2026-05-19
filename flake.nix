#############################################################
#
#  Flake - Root configuration for Filip's NixOS systems
#
#############################################################
{
  inputs = {
    # Nixpkgs unstable channel for latest packages and system drivers
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Flake-parts for clean, modular flake structures
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Impermanence for keeping root directories clean and ephemeral
    impermanence.url = "github:nix-community/impermanence";

    # Disko for declarative disk partitioning and formatting schemas
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home-Manager for declarative user environment and dotfiles management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SOPS-nix for system-level encrypted secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix for uniform system-wide customization and theme integration
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen-browser overlay package
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Otter-launcher source for TUI application launching
    otter-launcher = {
      url = "github:kuokuo123/otter-launcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware-specific profiles for mobile devices/laptops
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Neovim configuration framework
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    # YouTube Music Player client
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
    # Global variables shared across all configurations to avoid duplication
    globals = {
      stateVersion = "26.05";
      userName = "fucku";
      userEmail = "1";
      themeName = "carbon";
      gitPlatform = "2";
      gitUser = "3";
      gitRepo = "4";
      device = "/dev/nvme0n1";
      timeZone = "Europe/Warsaw";
    };

    # Helper function to generate standardized hosts
    mkHost = {
      hostName,
      system ? "x86_64-linux",
      hostConfig ? {},
      extraModules ? [],
    }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = let
          # TODO: switch to FOSS git host
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
            # Basic defaults for every host system
            {
              networking.hostName = hostName;
              system.stateVersion = globals.stateVersion;
              nixpkgs.config.allowUnfree = true;
            }

            # Dynamically import all system-wide and home modules
            ./modules/default.nix

            # Host-specific hardware, layouts, and app profiles
            ./hosts/${hostName}/default.nix
            ./hosts/${hostName}/hardware.nix
            ./hosts/${hostName}/disko.nix

            # Register standard external flake modules
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

        # Define host configurations
        nixosConfigurations = {
          # Primary gaming and development desktop
          aorus = mkHost {hostName = "aorus";};

          # Microsoft Surface Pro portable laptop
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
        # Formatter format tool for all nix source files in this repo
        formatter = pkgs.alejandra;

        # The default install script, run via "nix run" or "just switch-*"
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
