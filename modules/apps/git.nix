{ config, lib, pkgs, globals, ... }:
let
  cfg = config.apps.git;
in
{
  options.apps.git.enable = lib.mkEnableOption "git config";

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs.git = {
        enable = true;
        userName = globals.userName;
        userEmail = globals.userEmail;
        extraConfig = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          core.editor = "nvim";
        };
      };
    };
  };
}