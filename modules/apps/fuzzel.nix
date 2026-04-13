{ config, lib, pkgs, globals, ... }:
let
  cfg = config.apps.fuzzel;
in
{
  options.apps.fuzzel.enable = lib.mkEnableOption "fuzzel launcher";

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "BlexMono Nerd Font:size=11";
            dpi-aware = "yes";
            prompt = "> ";
            terminal = "foot -a '{cmd}' -T '{cmd}' -e {cmd}";
            width = 30;
            lines = 10;
            horizontal-pad = 20;
            vertical-pad = 20;
            inner-pad = 10;
            match-mode = "fzf";
            icons-enabled = "no";
          };
          border = {
            width = 4;
            radius = 0;
          };
        };
      };
    };
  };
}