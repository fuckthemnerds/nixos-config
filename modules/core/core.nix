{ config, lib, pkgs, inputs, userName, hostName, stateVersion, ... }:

{
  nix = {
    settings = {
      trusted-users = [ "root" userName ];
      allowed-users = [ "@wheel" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  environment.variables.FLAKE = "/home/${userName}/nixos-config";

  zramSwap.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs userName stateVersion hostName; };
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
    ];

    users.${userName} = {
      home.stateVersion = stateVersion;
      home.username = userName;
      home.homeDirectory = lib.mkForce "/home/${userName}";
    };
  };
}