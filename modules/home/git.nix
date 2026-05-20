{
  config,
  lib,
  pkgs,
  globals,
  inputs,
  myLib,
  ...
}: let
  cfg = config.apps.git;
in {
  options.apps.git.enable = myLib.mkEnableOpt "git configuration";

  config = myLib.mkIfEnabled cfg.enable (myLib.mkHome globals.userName {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = globals.userName;
          email = globals.userEmail;
        };
        init.defaultBranch = "main";
      };
    };

    programs.lazygit.enable = true;
  });
}
