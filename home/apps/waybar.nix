{ config, pkgs, lib, ... }:

let
	palette = config.theme.palette;
in
{
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
			font-family: "BlexMono Nerd Font", monospace;
			font-size: 11px;
			border: none;
			border-radius: 0;
			padding: 0;
			margin: 0;
			min-height: 0;
		}

		window#waybar {
			background-color: ${palette.layer01};
			color: ${palette.textPrimary};
		}

		#clock,
		#network,
		#bluetooth,
		#pulseaudio,
		#battery {
			padding: 0 10px;
			color: ${palette.textPrimary};
			background-color: transparent;
		}

		#clock:hover,
		#network:hover,
		#bluetooth:hover,
		#pulseaudio:hover,
		#battery:hover {
			background-color: ${palette.layer02};
		}

		#clock { color: ${palette.textSecondary}; }
		#network.disconnected { color: ${palette.layer03}; }
		#bluetooth.connected { color: ${palette.linkPrimary}; }
		#bluetooth.disabled { color: ${palette.layer03}; }
		#pulseaudio.muted { color: ${palette.textError}; }

		#battery.warning { color: ${palette.supportWarning}; }
		#battery.critical {
			color: ${palette.supportError};
			animation: blink 1s linear infinite;
		}
		#battery.charging,
		#battery.plugged { color: ${palette.supportSuccess}; }

		@keyframes blink {
			to {
				background-color: ${palette.supportError};
				color: ${palette.textPrimary};
			}
		}
		'';
	};
}
