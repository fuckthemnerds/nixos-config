{
  config,
  lib,
  pkgs,
  globals,
  hostName,
  myLib,
  ...
}: let
  cfg = config.apps.hyprlock;
in {
  config = myLib.mkIfEnabled cfg.enable (myLib.mkHome globals.userName {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "sleep 0.5 && niri msg action power-on-monitors";
        };
        listener =
          [
            {
              timeout = 149;
              on-timeout = "brightnessctl -s";
              on-resume = "brightnessctl -r";
            }
            {
              timeout = 150;
              on-timeout = "brightnessctl set 10%";
              on-resume = "";
            }
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330;
              on-timeout = "niri msg action power-off-monitors";
              on-resume = "niri msg action power-on-monitors";
            }
          ]
          ++ lib.optionals (hostName == "surface") [
            {
              timeout = 1800;
              on-timeout = "systemctl hibernate";
            }
          ];
      };
    };

    systemd.user.services.hypridle.Service.Restart = lib.mkForce "always";
  });
}
