{
  config,
  lib,
  pkgs,
  globals,
  ...
}: let
  cfg = config.apps.modern-cli;
in {
  options.apps.modern-cli.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs = {
        ripgrep.enable = true;
        fd.enable = true;

        eza = {
          enable = true;
          git = true;
          icons = "auto";
        };

        bat = {
          enable = true;
        };

        fzf = {
          enable = true;
          enableFishIntegration = true;
        };
      };

      home.packages = [pkgs.imagemagick];
    };
  };
}