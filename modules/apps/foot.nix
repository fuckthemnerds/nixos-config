{ config, lib, pkgs, globals, ... }:
let
  cfg = config.apps.foot;
in
{
  options.apps.foot.enable = lib.mkEnableOption "foot terminal";

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs.foot = {
        enable = true;
        server.enable = true;

        settings = {
          cursor = {
            style = "block";
            blink = "yes";
          };
          colors = {
            alpha = "0.9";
          };
        };
      };
    };
  };
}