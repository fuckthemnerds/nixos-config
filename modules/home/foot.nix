{
  config,
  lib,
  pkgs,
  globals,
  ...
}: let
  cfg = config.apps.foot;
  colors = config.lib.stylix.colors;
in {
  options.apps.foot.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs.foot = {
        enable = true;
        server.enable = true;

        settings = {
          main = {
            pad = "20x20";
          };
          cursor = {
            style = "block";
            blink = "yes";
          };
        };
      };
    };
  };
}
