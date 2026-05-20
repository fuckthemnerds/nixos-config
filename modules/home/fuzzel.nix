{
  config,
  lib,
  globals,
  myLib,
  ...
}: let
  cfg = config.apps.fuzzel;
in {
  options.apps.fuzzel.enable = myLib.mkEnableOpt "fuzzel launcher";

  config = myLib.mkIfEnabled cfg.enable (myLib.mkHome globals.userName {
    programs.fuzzel = {
      enable = true;
      settings = {
          main = {
            font = lib.mkForce "${config.stylix.fonts.monospace.name}:size=${toString config.stylix.fonts.sizes.applications}";
            prompt = ">  ";
            terminal = "footclient -a '{cmd}' -T '{cmd}' -e {cmd}";
            width = 30;
            lines = 10;
            horizontal-pad = 20;
            vertical-pad = 20;
            inner-pad = 10;
            match-mode = "fzf";
            icons-enabled = "no";
          };
          border = {
            width = 0;
            radius = 0;
          };
        };
      };
    });
}
