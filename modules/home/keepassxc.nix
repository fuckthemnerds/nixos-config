{
  config,
  lib,
  pkgs,
  globals,
  myLib,
  ...
}: let
  cfg = config.apps.keepassxc;
in {
  options.apps.keepassxc.enable = myLib.mkBoolOpt true "KeePassXC Password Manager";

  config = myLib.mkIfEnabled cfg.enable (myLib.mkHome globals.userName {
    programs.keepassxc = {
        enable = true;
        # TODO
        # 1. make config declarative
        # 2. fix daemon
        # 3. fix open on restart
        # 4. Use file to open (?)
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
    });
}
