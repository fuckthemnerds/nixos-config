# outputs/default.nix
inputs @ {
  self,
  nixpkgs,
  flake-parts,
  ...
}: let
  lib = nixpkgs.lib;
  myLib = import ../lib {inherit lib;};
  myVars = import ../vars {inherit lib;};

  mkHost = {
    hostName,
    system ? "x86_64-linux",
    hostConfig ? {},
    extraModules ? [],
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = let
        gitRemoteUrl =
          if (myVars ? gitPlatform && myVars.gitPlatform == "github")
          then "https://github.com/${myVars.gitUser}/${myVars.gitRepo}"
          else "";
      in {
        inherit inputs hostName gitRemoteUrl;
        globals = myVars;
        inherit (myVars) userName stateVersion;
      };
      modules =
        [
          {
            networking.hostName = hostName;
            system.stateVersion = myVars.stateVersion;
            nixpkgs.config.allowUnfree = true;
          }

          ../modules/default.nix

          ../hosts/${hostName}/default.nix
          ../hosts/${hostName}/hardware.nix
          ../hosts/${hostName}/disko.nix

          inputs.impermanence.nixosModules.impermanence
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          inputs.disko.nixosModules.disko
          inputs.stylix.nixosModules.stylix

          hostConfig
        ]
        ++ extraModules;
    };
in {
  systems = ["x86_64-linux"];

  flake = {
    globals = myVars;
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
}
