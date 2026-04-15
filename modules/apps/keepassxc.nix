{ config, lib, pkgs, globals, ... }:

let
  cfg = config.apps.keepassxc;
in
{
  options.apps.keepassxc.enable = lib.mkEnableOption "keepassxc";

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs.keepassxc = {
        enable = true;
        settings = {
          GUI = {
            ShowTrayIcon    = true;
            MinimizeToTray  = true;
            MinimizeOnClose = true;
          };
        };
      };

      systemd.user.services.keepassxc = {
        Unit = {
          Description = "KeePassXC Password Manager";
          After       = [ "graphical-session.target" "waybar.service" ];
          PartOf      = [ "graphical-session.target" ];
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.keepassxc}/bin/keepassxc --minimized";
          Restart   = "on-failure";
          RestartSec = "3s";
        };
      };
    };
  };
}