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
        user.Name = globals.userName;
        user.Email = globals.userEmail;
        extraConfig = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          core.editor = "nvim";
        };
      };
    };
  };
}