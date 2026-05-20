{
  config,
  lib,
  pkgs,
  globals,
  myLib,
  ...
}: let
  cfg = config.apps.btop;
in {
  options.apps.btop.enable = myLib.mkEnableOpt "btop system monitor";

  config = myLib.mkIfEnabled cfg.enable (myLib.mkHome globals.userName {
    programs.btop = {
      enable = true;
      settings = {
        theme_background = true;
        truecolor = true;
        vim_keys = true;
        rounded_corners = false;
        graph_symbol = "braille";
        shown_boxes = "cpu mem net proc";
      };
    };
  });
}
