{ config, lib, pkgs, globals, ... }:

let
  cfg = config.apps.rclone;
in
{
  options.apps.rclone.enable = lib.mkEnableOption "rclone";

  config = lib.mkIf cfg.enable {
    programs.fuse.userAllowOther = true;
    environment.systemPackages = [ pkgs.rclone ];

    sops.secrets."rclone.conf" = {
      owner = globals.userName;
    };

    home-manager.users.${globals.userName} = {
      home.file."gdrive/.keep".text = "";

      systemd.user.services.rclone-gdrive = {
        Unit = {
          Description = "rclone Google Drive mount";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Type = "notify";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/gdrive";
          ExecStart = ''
            ${pkgs.rclone}/bin/rclone mount gdrive: %h/gdrive \
              --config=${config.sops.secrets."rclone.conf".path} \
              --vfs-cache-mode full \
              --vfs-cache-max-size 20G \
              --vfs-cache-max-age 24h \
              --vfs-read-chunk-size 128M \
              --vfs-read-chunk-size-limit off \
              --buffer-size 256M \
              --drive-chunk-size 128M \
              --drive-acknowledge-abuse \
              --transfers 8 \
              --checkers 16 \
              --poll-interval 30s \
              --dir-cache-time 72h \
              --allow-other
          '';
          ExecStop = "/run/wrappers/bin/fusermount -u %h/gdrive";
          Restart = "on-failure";
          RestartSec = "10s";
          Environment = [ "PATH=/run/wrappers/bin:$PATH" ];
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
