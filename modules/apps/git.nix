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
          settings = {
            user = {
              name = globals.userName;
              email = globals.userEmail;
            };
            init.defaultBranch = "main";
          };
        };

      programs.lazygit.enable = true;
    };
  };
}