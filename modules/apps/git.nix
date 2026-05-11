{
  config,
  lib,
  pkgs,
  globals,
  inputs,
  ...
}: let
  cfg = config.apps.git;
in {
  options.apps.git.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      config,
      ...
    }: {
      programs.git = {
        enable = true;
        userName = globals.userName;
        userEmail = globals.userEmail;
        extraConfig = {
          init.defaultBranch = "main";
        };
      };

      programs.lazygit.enable = true;
    };
  };
}