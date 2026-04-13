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
          main = {
            font = "BlexMono Nerd Font:size=11";
            dpi-aware = "yes";
            pad = "20x20";
          };
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