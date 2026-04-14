{ config, lib, pkgs, userName, ... }:
let
  cfg = config.apps.waybar;
  palette = config.lib.stylix.colors.withHashtag;
in
{
  options.apps.waybar.enable = lib.mkEnableOption "waybar";

  config = lib.mkIf cfg.enable {
    home-manager.users.${userName} = {
      programs.waybar = {
        enable = true;
        settings = [{
          layer = "top";
          position = "top";
          height = 28;
          spacing = 0;
          exclusive = true;
          fixed-center = false;

          modules-left = [ "clock#date" ];
          modules-center = [ "clock" ];
          modules-right = [ "network" "bluetooth" "pulseaudio" "battery" ];

          "clock#date" = {
            format = "{0:%A}";
            format-alt = "{0:%A, %m/%d}";
            tooltip = false;
          };

          "clock" = {
            format = "{0:%H:%M}";
            tooltip = false;
          };

          "network" = {
            format-wifi = "{icon}";
            format-ethernet = "󰈀";
            format-disconnected = "󰤭";
            format-linked = "󰤫";
            format-icons = [ "󰤟" "󰤢" "󰤥" "󰤨" ];
            tooltip-format-wifi = "{essid}  {signalStrength}%";
            tooltip-format-disconnected = "Disconnected";
            on-click = "foot --app-id impala impala";
          };

          "bluetooth" = {
            format = "󰂯";
            format-connected = "󰂱";
            format-disabled = "󰂲";
            tooltip = false;
            on-click = "foot --app-id bluetui bluetui";
          };

          "pulseaudio" = {
            format = "{icon}";
            format-muted = "󰖁";
            format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
            tooltip = false;
            on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-click-right = "foot --app-id wiremix wiremix";
            scroll-step = 5;
          };

          "battery" = {
            format = "{icon}";
            format-charging = "󰂄";
            format-plugged = "󰚥";
            format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
            states = {
              warning = 30;
              critical = 15;
            };
            tooltip = false;
            on-click = "foot --app-id btop btop";
          };
        }];

        style = ''
          * {
            font-family: ${config.stylix.fonts.monospace.name};
            font-size: 11px;
            border: none;
            border-radius: 0;
            padding: 0;
            margin: 0;
            min-height: 0;
          }

          window#waybar {
            background-color: ${palette.base01};
            color: ${palette.base05};
          }

          #clock, #network, #bluetooth, #pulseaudio, #battery {
            padding: 0 10px;
            color: ${palette.base05};
            background-color: transparent;
          }

          #clock:hover, #network:hover, #bluetooth:hover, #pulseaudio:hover, #battery:hover {
            background-color: ${palette.base02};
          }

          #clock { color: ${palette.base06}; }
          #network.disconnected { color: ${palette.base03}; }
          #bluetooth.connected { color: ${palette.base0D}; }
          #bluetooth.disabled { color: ${palette.base03}; }
          #pulseaudio.muted { color: ${palette.base09}; }

          #battery.warning { color: ${palette.base0A}; }
          #battery.critical {
            color: ${palette.base08};
            animation: blink 1s linear infinite;
          }
          #battery.charging, #battery.plugged { color: ${palette.base0B}; }

          @keyframes blink {
            to {
              background-color: ${palette.base08};
              color: ${palette.base05};
            }
          }
        '';
      };
      stylix.targets.waybar.enable = false;
    };
  };
}