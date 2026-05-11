{
  config,
  lib,
  pkgs,
  globals,
  ...
}: let
  cfg = config.apps.gui-apps;
in {
  options.apps.gui-apps.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      home.packages = with pkgs; [
        teams-for-linux
        file-roller
        libreoffice-fresh
      ];
    };
  };
}