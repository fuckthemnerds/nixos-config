{
  config,
  lib,
  pkgs,
  globals,
  myLib,
  ...
}: let
  cfg = config.apps.foot;
in {
  options.apps.foot.enable = myLib.mkEnableOpt "foot terminal";

  config = myLib.mkIfEnabled cfg.enable (myLib.mkHome globals.userName {
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
  });
}
