{
  config,
  lib,
  pkgs,
  globals,
  ...
}: let
  cfg = config.apps.zoxide;
in {
  options.apps.zoxide.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = ["--cmd z"];
      };
    };
  };
}