{ config, lib, hostName, ... }:

let
	palette = config.theme.palette;
	sh = cmd: config.lib.niri.actions.spawn "sh" "-c" cmd;
in
{

	programs.niri.settings = {
		outputs = lib.mkMerge [
			(lib.mkIf (hostName == "aorus") {
				"eDP-1" = {
					mode = {
						width = 2560;
						height = 1440;
						refresh = 165.0;
					};
					scale = 1.0;
				};
				"HDMI-A-1" = {
					mode = {
						width = 2560;
						height = 1440;
						refresh = 144.0;
					};
					scale = 1.0;
					position = { x = 2560; y = 0; };
				};
			})
			(lib.mkIf (hostName == "surface") {
				"eDP-1" = {
					mode = {
						width = 2880;
						height = 1920;
						refresh = 120.0;
					};
					scale = 2.0;
				};
			})
		];

		prefer-no-csd = true;
		hotkey-overlay.skip-at-startup = true;
		screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

		input = {
			keyboard = {
				xkb = {
					layout = "pl";
					options = "ctrl:nocaps";
				};
				numlock = true;
			};

			touchpad = {
				tap = true;
				natural-scroll = true;
			};
		};

		layout = {
			background-color = palette.layer01;
			gaps = 0;
			center-focused-column = "never";

			default-column-width.proportion = 1.0;

			preset-column-widths = [
				{ proportion = 1.0 / 3.0; }
				{ proportion = 2.0 / 3.0; }
				{ proportion = 1.0; }
			];

			preset-window-heights = [
				{ proportion = 1.0 / 3.0; }
				{ proportion = 2.0 / 3.0; }
				{ proportion = 1.0; }
			];

			focus-ring = {
				enable = true;
				width = 4;
				active.color = palette.focus;
				inactive.color = palette.layer01;
			};

			border = {
				enable = false;
				width = 4;
				active.color = palette.interactive;
				inactive.color = palette.borderSubtle;
				urgent.color = palette.supportError;
			};

			shadow.enable = false;
		};

		spawn-at-startup = [
			{ command = [ "waybar" ]; }
		];

		window-rules = [
			{
				open-maximized = true;
			}
			{
				matches = [ { app-id = "^org\\.keepassxc\\.KeePassXC$"; } ];
				open-floating = true;
				default-column-width.proportion = 0.6;
				default-window-height.proportion = 0.6;
			}
			{
				matches = [
					{ app-id = "^impala$"; }
					{ app-id = "^wiremix$"; }
					{ app-id = "^btop$"; }
					{ app-id = "^bluetui$"; }
				];
				open-floating = true;
				default-column-width.proportion = 0.8;
				default-window-height.proportion = 0.8;
			}
			{
				matches = [
					{ app-id = "firefox$"; title = "^Picture-in-Picture$"; }
				];
				open-floating = true;
			}
			{
				matches = [ { is-floating = true; } ];
				default-column-width.proportion = 0.6;
				default-window-height.proportion = 0.6;
			}
		];

		binds = with config.lib.niri.actions; {
			"Mod+Space".action = spawn "fuzzel";
			"Mod+Return".action = spawn "foot";
			"Mod+V".action = sh "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy";
			"Super+F1".action = sh "killall -SIGUSR1 waybar";

			"XF86AudioRaiseVolume" = {
				action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
				allow-when-locked = true;
			};
			"XF86AudioLowerVolume" = {
				action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
				allow-when-locked = true;
			};
			"XF86AudioMute" = {
				action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
				allow-when-locked = true;
			};
			"XF86AudioMicMute" = {
				action = sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
				allow-when-locked = true;
			};
			"XF86AudioPlay" = {
				action = sh "playerctl play-pause";
				allow-when-locked = true;
			};
			"XF86AudioStop" = {
				action = sh "playerctl stop";
				allow-when-locked = true;
			};
			"XF86AudioPrev" = {
				action = sh "playerctl previous";
				allow-when-locked = true;
			};
			"XF86AudioNext" = {
				action = sh "playerctl next";
				allow-when-locked = true;
			};

			"XF86MonBrightnessUp" = {
				action = spawn [ "brightnessctl" "--class=backlight" "set" "+10%" ];
				allow-when-locked = true;
			};
			"XF86MonBrightnessDown" = {
				action = spawn [ "brightnessctl" "--class=backlight" "set" "10%-" ];
				allow-when-locked = true;
			};

			"Mod+Q" = { action.close-window = []; repeat = false; };
 
			"Mod+H".action.focus-column-left = [];
			"Mod+L".action.focus-column-right = [];
			"Mod+A".action.focus-column-left = [];
			"Mod+D".action.focus-column-right = [];
			"Mod+J".action.focus-window-down = [];
			"Mod+K".action.focus-window-up = [];
			"Mod+S".action.focus-window-down = [];
			"Mod+W".action.focus-window-up = [];

			"Mod+Shift+H".action.move-column-left = [];
			"Mod+Shift+L".action.move-column-right = [];
			"Mod+Shift+A".action.move-column-left = [];
			"Mod+Shift+D".action.move-column-right = [];
			"Mod+Shift+K".action.move-window-up-or-to-workspace-up = [];
			"Mod+Shift+W".action.move-window-up-or-to-workspace-up = [];
			"Mod+Shift+J".action.move-window-down-or-to-workspace-down = [];
			"Mod+Shift+S".action.move-window-down-or-to-workspace-down = [];

			"Mod+Shift+Ctrl+H".action.focus-monitor-left = [];
			"Mod+Shift+Ctrl+L".action.focus-monitor-right = [];
			"Mod+Shift+Ctrl+A".action.focus-monitor-left = [];
			"Mod+Shift+Ctrl+D".action.focus-monitor-right = [];
			"Mod+Shift+Ctrl+J".action.focus-monitor-down = [];
			"Mod+Shift+Ctrl+K".action.focus-monitor-up = [];
			"Mod+Shift+Ctrl+S".action.focus-monitor-down = [];
			"Mod+Shift+Ctrl+W".action.focus-monitor-up = [];

			"Mod+Alt+Shift+H".action.move-column-to-monitor-left = [];
			"Mod+Alt+Shift+L".action.move-column-to-monitor-right = [];
			"Mod+Alt+Shift+A".action.move-column-to-monitor-left = [];
			"Mod+Alt+Shift+D".action.move-column-to-monitor-right = [];
			"Mod+Alt+Shift+J".action.move-column-to-monitor-down = [];
			"Mod+Alt+Shift+K".action.move-column-to-monitor-up = [];
			"Mod+Alt+Shift+S".action.move-column-to-monitor-down = [];
			"Mod+Alt+Shift+W".action.move-column-to-monitor-up = [];

			"Mod+Ctrl+K".action.focus-workspace-up = [];
			"Mod+Ctrl+W".action.focus-workspace-up = [];
			"Mod+Ctrl+J".action.focus-workspace-down = [];
			"Mod+Ctrl+S".action.focus-workspace-down = [];

			"Mod+1".action.focus-workspace = 1;
			"Mod+2".action.focus-workspace = 2;
			"Mod+3".action.focus-workspace = 3;
			"Mod+4".action.focus-workspace = 4;
			"Mod+5".action.focus-workspace = 5;
			"Mod+6".action.focus-workspace = 6;
			"Mod+7".action.focus-workspace = 7;
			"Mod+8".action.focus-workspace = 8;
			"Mod+9".action.focus-workspace = 9;

			"Mod+Ctrl+1".action.move-column-to-workspace = 1;
			"Mod+Ctrl+2".action.move-column-to-workspace = 2;
			"Mod+Ctrl+3".action.move-column-to-workspace = 3;
			"Mod+Ctrl+4".action.move-column-to-workspace = 4;
			"Mod+Ctrl+5".action.move-column-to-workspace = 5;
			"Mod+Ctrl+6".action.move-column-to-workspace = 6;
			"Mod+Ctrl+7".action.move-column-to-workspace = 7;
			"Mod+Ctrl+8".action.move-column-to-workspace = 8;
			"Mod+Ctrl+9".action.move-column-to-workspace = 9;

			"Mod+WheelScrollDown" = { action.focus-workspace-down = []; cooldown-ms = 150; };
			"Mod+WheelScrollUp"   = { action.focus-workspace-up = [];   cooldown-ms = 150; };
			"Mod+Ctrl+WheelScrollDown" = { action.move-column-to-workspace-down = []; cooldown-ms = 150; };
			"Mod+Ctrl+WheelScrollUp"   = { action.move-column-to-workspace-up = [];   cooldown-ms = 150; };

			"Mod+WheelScrollRight".action.focus-column-right = [];
			"Mod+WheelScrollLeft".action.focus-column-left = [];
			"Mod+Ctrl+WheelScrollRight".action.move-column-right = [];
			"Mod+Ctrl+WheelScrollLeft".action.move-column-left = [];

			"Mod+Ctrl+H".action.consume-or-expel-window-left = [];
			"Mod+Ctrl+A".action.consume-or-expel-window-left = [];
			"Mod+Ctrl+L".action.consume-or-expel-window-right = [];
			"Mod+Ctrl+D".action.consume-or-expel-window-right = [];

			"Mod+R".action.switch-preset-column-width = [];
			"Mod+Shift+R".action.switch-preset-window-height = [];
			"Mod+F".action.fullscreen-window = [];
			"Mod+Shift+F".action.maximize-column = [];
			"Mod+Ctrl+F".action.expand-column-to-available-width = [];

			"Mod+Minus".action.set-column-width = "-10%";
			"Mod+Equal".action.set-column-width = "+10%";
			"Mod+Shift+Minus".action.set-window-height = "-10%";
			"Mod+Shift+Equal".action.set-window-height = "+10%";

			"Mod+Shift+M".action = spawn "niri-toggle-float";
			"Mod+M".action.switch-focus-between-floating-and-tiling = [];
			"Mod+Ctrl+M".action = spawn "niri-cycle-floating";

			"Mod+grave" = { action.toggle-overview = []; repeat = false; };

			"Print".action.screenshot = [];
			"Ctrl+Print".action.screenshot-screen = [];

			"Mod+Escape" = { action.toggle-keyboard-shortcuts-inhibit = []; allow-inhibiting = false; };
			"Mod+P".action = spawn "niri-power-menu";
			"Mod+Shift+E".action.quit = [];
			"Ctrl+Alt+Delete".action.quit = [];
			"Mod+Shift+P".action.power-off-monitors = [];
		};
	};
}
