{
  lib,
  inputs,
  userName,
  hostName,
  stateVersion,
  myLib,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit inputs userName stateVersion hostName myLib;};
    sharedModules = [];

    users.${userName} = {
      home.stateVersion = stateVersion;
      home.username = userName;
      home.homeDirectory = lib.mkForce "/home/${userName}";
      manual.manpages.enable = false;
    };
  };
}
