{
  config,
  lib,
  pkgs,
  globals,
  ...
}: let
  cfg = config.apps.ai;
in {
  options.apps.ai.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      home.packages = with pkgs; [
        opencode
        antigravity
      ];
    };
  };
}