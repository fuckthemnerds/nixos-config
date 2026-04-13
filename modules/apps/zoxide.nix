{ config, lib, pkgs, globals, ... }:
let
  cfg = config.apps.zoxide;
in
{
  options.apps.zoxide.enable = lib.mkEnableOption "zoxide directory jumper";

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [ "--cmd z" ];
      };
    };
  };
}