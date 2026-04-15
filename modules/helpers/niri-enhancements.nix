{ config, lib, pkgs, hostName, ... }:
let
	cfg = config.apps.niri-enhancements;
in
{
	options.apps.niri-enhancements.enable = lib.mkEnableOption "niri-enhancements";

	config = lib.mkIf cfg.enable {
		environment.systemPackages = [
			(pkgs.writeShellScriptBin "niri-cycle-floating" ''
			STATE_FILE=/tmp/niri_floating_pos_state
			GAP=8
			WAYBAR_HEIGHT=28

			WIN=$(niri msg --json windows | ${pkgs.jq}/bin/jq 'map(select(.is_focused == true)) | .[0]')
			WIN_W=$(echo "$WIN" | ${pkgs.jq}/bin/jq '.layout.window_size[0]')
			WIN_H=$(echo "$WIN" | ${pkgs.jq}/bin/jq '.layout.window_size[1]')

			OUT=$(niri msg --json outputs | ${pkgs.jq}/bin/jq 'to_entries[0].value')
			OUT_W=$(echo "$OUT" | ${pkgs.jq}/bin/jq '.logical.width')
			OUT_H=$(echo "$OUT" | ${pkgs.jq}/bin/jq '.logical.height')

			if pgrep -x waybar > /dev/null; then
			BOTTOM_GAP=$(( GAP + WAYBAR_HEIGHT ))
			else
			BOTTOM_GAP=$GAP
			fi

			POSITIONS=(
				"$(( OUT_W - WIN_W - GAP )) $GAP"
				"$GAP $GAP"
				"$GAP $(( OUT_H - WIN_H - BOTTOM_GAP ))"
				"$(( OUT_W - WIN_W - GAP )) $(( OUT_H - WIN_H - BOTTOM_GAP ))"
			)

			if [[ -f "$STATE_FILE" ]]; then
			CURRENT_INDEX=$(cat "$STATE_FILE")
			else
			CURRENT_INDEX=0
			fi

			read -r X Y <<< "$\{POSITIONS[$CURRENT_INDEX]}"

			niri msg action move-floating-window --x "$X" --y "$Y"

			NEXT_INDEX=$(( (CURRENT_INDEX + 1) % $\{#POSITIONS[@]} ))
			echo "$NEXT_INDEX" > "$STATE_FILE"
			'')

			(pkgs.writeShellScriptBin "niri-toggle-float" ''
			IS_FLOATING=$(niri msg --json windows | ${pkgs.jq}/bin/jq 'map(select(.is_focused == true)) | .[0].is_floating')

			niri msg action toggle-window-floating

			if [[ "$IS_FLOATING" == "false" ]]; then
			sleep 0.05
			niri msg action set-column-width "60%"
			niri msg action set-window-height "60%"
			niri msg action center-column
			fi
			'')

			(pkgs.writeShellScriptBin "niri-power-menu" ''
			OPTIONS="Lock\nLog out\nReboot\nPower Off"
			${lib.optionalString (hostName == "surface") ''OPTIONS="$OPTIONS\nHibernate"''}

			SELECTION="$(printf "$OPTIONS" | ${pkgs.fuzzel}/bin/fuzzel --dmenu -l 5 -p "> ")"

			case $SELECTION in
			"Lock")      hyprlock ;;
			"Hibernate") systemctl hibernate ;;
			"Log out")   niri msg action quit ;;
			"Reboot")    systemctl reboot ;;
			"Power Off")  systemctl poweroff ;;
			esac
			'')
		];
	};
}