{ config, lib, pkgs, userName, hostName, ... }:
let
  cfg = config.apps.niri;
  colors = config.lib.stylix.colors.withHashtag;

  aorusOutputs = ''
    output "eDP-1" {
        mode "2560x1440@165.0"
        scale 1.0
    }
    output "HDMI-A-1" {
        mode "2560x1440@144.0"
        scale 1.0
        position x=2560 y=0
    }
  '';

  surfaceOutputs = ''
    output "eDP-1" {
        mode "2880x1920@120.0"
        scale 2.0
    }
  '';

  outputs = if hostName == "aorus" then aorusOutputs else if hostName == "surface" then surfaceOutputs else "";
in
{
  options.apps.niri.enable = lib.mkEnableOption "niri";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;

    home-manager.users.${userName} = {
      home.packages = with pkgs; [
        wl-clipboard
        brightnessctl
        playerctl
        grim
        slurp
        swappy
        xdg-utils
        adw-gtk3

        impala
        pulsemixer
      ];

      xdg.configFile."niri/config.kdl".text = ''
        prefer-no-csd
        hotkey-overlay {
            skip-at-startup
        }

        cursor {
            hide-when-typing
            hide-after-inactive-ms 3000
        }

        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

        input {
            keyboard {
                xkb {
                    layout "pl"
                    options "ctrl:nocaps"
                }
            }
            touchpad {
                tap
                natural-scroll
            }
        }

        layout {
            gaps 0
            center-focused-column "never"

            default-column-width { proportion 1.0; }

            preset-column-widths {
                proportion 0.33333
                proportion 0.66667
                proportion 1.0
            }

            preset-window-heights {
                proportion 0.33333
                proportion 0.66667
                proportion 1.0
            }

            focus-ring {
                off
                width 4
                active-color "${colors.base07}"
                inactive-color "${colors.base01}"
            }

            border {
                off
                width 4
                active-color "${colors.base0D}"
                inactive-color "${colors.base03}"
            }

            shadow {
                on
            }
        }

        ${outputs}

        spawn-at-startup "waybar"

        window-rule {
            open-maximized true
        }
        window-rule {
            match app-id="^org\\.keepassxc\\.KeePassXC$"
            open-floating true
            default-column-width { proportion 0.6; }
            default-window-height { proportion 0.6; }
        }
        window-rule {
            match app-id="^impala$"
            match app-id="^wiremix$"
            match app-id="^btop$"
            match app-id="^bluetui$"
            open-floating true
            default-column-width { proportion 0.8; }
            default-window-height { proportion 0.8; }
        }
        window-rule {
            match app-id="firefox$" title="^Picture-in-Picture$"
            open-floating true
        }
        window-rule {
            match is-floating=true
            default-column-width { proportion 0.6; }
            default-window-height { proportion 0.6; }
        }

        binds {
            Mod+Space { spawn "fuzzel"; }
            Mod+Return { spawn "foot"; }
            Mod+V { spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"; }
            Super+F1 { spawn "sh" "-c" "killall -SIGUSR1 waybar"; }

            XF86AudioRaiseVolume allow-when-locked=true { spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
            XF86AudioMute allow-when-locked=true { spawn "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
            XF86AudioMicMute allow-when-locked=true { spawn "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
            XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
            XF86AudioStop allow-when-locked=true { spawn "playerctl" "stop"; }
            XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }
            XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }

            XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
            XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

            Mod+Q { close-window; }

            Mod+H { focus-column-left; }
            Mod+L { focus-column-right; }
            Mod+A { focus-column-left; }
            Mod+D { focus-column-right; }
            Mod+J { focus-window-down; }
            Mod+K { focus-window-up; }
            Mod+S { focus-window-down; }
            Mod+W { focus-window-up; }

            Mod+Shift+H { move-column-left; }
            Mod+Shift+L { move-column-right; }
            Mod+Shift+A { move-column-left; }
            Mod+Shift+D { move-column-right; }
            Mod+Shift+K { move-window-up-or-to-workspace-up; }
            Mod+Shift+W { move-window-up-or-to-workspace-up; }
            Mod+Shift+J { move-window-down-or-to-workspace-down; }
            Mod+Shift+S { move-window-down-or-to-workspace-down; }

            Mod+Shift+Ctrl+H { focus-monitor-left; }
            Mod+Shift+Ctrl+L { focus-monitor-right; }
            Mod+Shift+Ctrl+A { focus-monitor-left; }
            Mod+Shift+Ctrl+D { focus-monitor-right; }
            Mod+Shift+Ctrl+J { focus-monitor-down; }
            Mod+Shift+Ctrl+K { focus-monitor-up; }
            Mod+Shift+Ctrl+S { focus-monitor-down; }
            Mod+Shift+Ctrl+W { focus-monitor-up; }

            Mod+Alt+Shift+H { move-column-to-monitor-left; }
            Mod+Alt+Shift+L { move-column-to-monitor-right; }
            Mod+Alt+Shift+A { move-column-to-monitor-left; }
            Mod+Alt+Shift+D { move-column-to-monitor-right; }
            Mod+Alt+Shift+J { move-column-to-monitor-down; }
            Mod+Alt+Shift+K { move-column-to-monitor-up; }
            Mod+Alt+Shift+S { move-column-to-monitor-down; }
            Mod+Alt+Shift+W { move-column-to-monitor-up; }

            Mod+Ctrl+K { focus-workspace-up; }
            Mod+Ctrl+W { focus-workspace-up; }
            Mod+Ctrl+J { focus-workspace-down; }
            Mod+Ctrl+S { focus-workspace-down; }

            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+7 { focus-workspace 7; }
            Mod+8 { focus-workspace 8; }
            Mod+9 { focus-workspace 9; }

            Mod+Ctrl+1 { move-column-to-workspace 1; }
            Mod+Ctrl+2 { move-column-to-workspace 2; }
            Mod+Ctrl+3 { move-column-to-workspace 3; }
            Mod+Ctrl+4 { move-column-to-workspace 4; }
            Mod+Ctrl+5 { move-column-to-workspace 5; }
            Mod+Ctrl+6 { move-column-to-workspace 6; }
            Mod+Ctrl+7 { move-column-to-workspace 7; }
            Mod+Ctrl+8 { move-column-to-workspace 8; }
            Mod+Ctrl+9 { move-column-to-workspace 9; }

            Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
            Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }
            Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
            Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

            Mod+WheelScrollRight { focus-column-right; }
            Mod+WheelScrollLeft { focus-column-left; }
            Mod+Ctrl+WheelScrollRight { move-column-right; }
            Mod+Ctrl+WheelScrollLeft { move-column-left; }

            Mod+Ctrl+H { consume-or-expel-window-left; }
            Mod+Ctrl+A { consume-or-expel-window-left; }
            Mod+Ctrl+L { consume-or-expel-window-right; }
            Mod+Ctrl+D { consume-or-expel-window-right; }

            Mod+R { switch-preset-column-width; }
            Mod+Shift+R { switch-preset-window-height; }
            Mod+F { fullscreen-window; }
            Mod+Shift+F { maximize-column; }
            Mod+Ctrl+F { expand-column-to-available-width; }

            Mod+Minus { set-column-width "-10%"; }
            Mod+Equal { set-column-width "+10%"; }
            Mod+Shift+Minus { set-window-height "-10%"; }
            Mod+Shift+Equal { set-window-height "+10%"; }

            Mod+Shift+M { spawn "niri-toggle-float"; }
            Mod+M { switch-focus-between-floating-and-tiling; }
            Mod+Ctrl+M { spawn "niri-cycle-floating"; }

            Mod+grave { toggle-overview; }

            Print { screenshot; }
            Ctrl+Print { screenshot-screen; }

            Mod+Escape { toggle-keyboard-shortcuts-inhibit; }
            Mod+P { spawn "niri-power-menu"; }
            Mod+Shift+E { quit; }
            Ctrl+Alt+Delete { quit; }
            Mod+Shift+P { power-off-monitors; }
        }
      '';
    };
  };
}