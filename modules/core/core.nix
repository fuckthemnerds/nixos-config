{ config, lib, pkgs, inputs, userName, hostName, stateVersion, ... }:

{
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