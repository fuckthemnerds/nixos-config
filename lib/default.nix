# lib/default.nix
{lib, ...}: {
  mkBoolOpt = default: description: lib.mkOption {
    type = lib.types.bool;
    inherit default description;
  };

  mkEnableOpt = description: lib.mkOption {
    type = lib.types.bool;
    default = false;
    inherit description;
  };

  mkHome = userName: config: {
    home-manager.users.${userName} = config;
  };

  mkIfEnabled = enable: config: lib.mkIf enable config;
}
