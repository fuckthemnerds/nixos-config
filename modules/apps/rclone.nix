{ config, lib, pkgs, globals, ... }:

let
  cfg = config.apps.rclone;
in
{
  options.apps.rclone.enable = lib.mkEnableOption "rclone";

  config = lib.mkIf cfg.enable {
    programs.fuse.userAllowOther = true;
    environment.systemPackages = [ pkgs.rclone ];

    sops.secrets.rclone_client_id.sopsFile = ../../secrets/rclone.yaml;
    sops.secrets.rclone_token.sopsFile = ../../secrets/rclone.yaml;

    sops.templates."rclone.conf" = {
      owner = globals.userName;
      content = ''
        [gdrive]
        type = drive
        client_id = ${config.sops.placeholder.rclone_client_id}
        token = ${config.sops.placeholder.rclone_token}
      '';
    };

    home-manager.users.${globals.userName} = { osConfig, config, ... }: {
      home.file."gdrive/.keep".text = "";

      xdg.configFile."rclone/rclone.conf".source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.templates."rclone.conf".path;

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
              --config=%h/.config/rclone/rclone.conf \
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
