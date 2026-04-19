{ config, lib, pkgs, globals, inputs, ... }:
let
  cfg = config.apps.git;
in
{
  options.apps.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = { config, ... }: {
      programs.git = {
        enable = true;
        userName = globals.userName;
        userEmail = globals.userEmail;
        extraConfig = {
          init.defaultBranch = "main";
          credential.helper = "store --file ~/.config/git/credentials";
        };
      };
    };
  };
}