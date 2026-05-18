{
  config,
  lib,
  pkgs,
  globals,
  ...
}: let
  cfg = config.apps.keepassxc;
in {
  options.apps.keepassxc.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs.keepassxc = {
        enable = true;
        # TODO 
        # 1. make config declarative
        # 2. fix daemon
        # 3. fix open on restart
      };

      systemd.user.services.keepassxc = {
        Unit = {
          Description = "KeePassXC Password Manager";
          After = ["graphical-session.target" "rclone-gdrive.service"];
          Wants = ["rclone-gdrive.service"];
          PartOf = ["graphical-session.target"];
          X-SwitchMethod = "keep-old";
        };

        Install = {
          WantedBy = ["graphical-session.target"];
        };

        Service = {
          ExecStart = "${pkgs.keepassxc}/bin/keepassxc --minimized";
          Restart = "on-failure";
          RestartSec = "3s";
        };
      };
    };
  };
}

