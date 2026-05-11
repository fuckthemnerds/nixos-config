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
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      stylix.targets.foot.enable = false;
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
            color = "${colors.base01} ${colors.base05}";
          };
          colors = {
            alpha = "0.9";
            background = colors.base01;
            foreground = colors.base05;
            regular0 = colors.base01;
            regular1 = colors.base08;
            regular2 = colors.base0B;
            regular3 = colors.base0A;
            regular4 = colors.base0D;
            regular5 = colors.base0E;
            regular6 = colors.base0C;
            regular7 = colors.base05;
            bright0 = colors.base03;
            bright1 = colors.base08;
            bright2 = colors.base0B;
            bright3 = colors.base0A;
            bright4 = colors.base0D;
            bright5 = colors.base0E;
            bright6 = colors.base0C;
            bright7 = colors.base07;
          };
        };
      };
    };
  };
}