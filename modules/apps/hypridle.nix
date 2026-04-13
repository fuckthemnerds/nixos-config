{ config, lib, pkgs, globals, hostName, ... }:
let
	cfg = config.apps.hypridle;
in
{
	options.apps.hypridle.enable = lib.mkEnableOption "hypridle daemon";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			services.hypridle = {
				enable = true;
				settings = {
					general = {
						lock_cmd = "pidof hyprlock || hyprlock";
						before_sleep_cmd = "loginctl lock-session";
						after_sleep_cmd = "niri msg action power-on-monitors";
					};
					listener = [
						{
							timeout = 150;
							on-timeout = "brightnessctl -s set 10";
							on-resume = "brightnessctl -r";
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
					] ++ lib.optionals (hostName == "surface") [
						{
							timeout = 1800;
							on-timeout = "systemctl hibernate";
						}
					];
				};
			};
					on-timeout = "systemctl hibernate";
				}
			];
		};
	};
}