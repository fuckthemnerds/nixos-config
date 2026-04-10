{ config, pkgs, ... }:

let
	palette = config.theme.palette;
	raw = s: builtins.substring 1 6 s;
in
{
	programs.fish = {
		enable = true;

		plugins = [
			{
				name = "fzf.fish";
				src = pkgs.fishPlugins.fzf-fish.src;
			}
			{
				name = "tide";
				src = pkgs.fishPlugins.tide.src;
			}
		];

		interactiveShellInit = ''
		fastfetch
		set -g fish_greeting
		fish_vi_key_bindings

		set -g tide_left_prompt_items pwd git newline character
		set -g tide_right_prompt_items status cmd_duration jobs direnv

		set -g tide_pwd_color_dirs ${raw palette.syntaxAttribute}
		set -g tide_pwd_color_anchors ${raw palette.syntaxControl}
		set -g tide_character_color ${raw palette.focus}
		set -g tide_character_color_vi_mode_insert ${raw palette.syntaxControl}
		set -g tide_character_color_vi_mode_normal ${raw palette.syntaxAttribute}
		set -g tide_git_color_branch ${raw palette.syntaxString}
		set -g tide_status_color ${raw palette.textError}
		set -g tide_cmd_duration_color ${raw palette.textHelper}
		set -g tide_cmd_duration_threshold 3000
		set -g tide_cmd_duration_decimals 0

		set -g fish_color_normal ${raw palette.textPrimary}
		set -g fish_color_command ${raw palette.syntaxAttribute}
		set -g fish_color_keyword ${raw palette.syntaxControl}
		set -g fish_color_quote ${raw palette.textPrimary}
		set -g fish_color_redirection ${raw palette.textSecondary}
		set -g fish_color_end ${raw palette.syntaxTag}
		set -g fish_color_error ${raw palette.textError}
		set -g fish_color_param ${raw palette.textPrimary}
		set -g fish_color_comment ${raw palette.syntaxComment}
		set -g fish_color_match --background=${raw palette.layer01}
		set -g fish_color_selection --background=${raw palette.layer02}
		set -g fish_color_search_match --background=${raw palette.layer02}
		set -g fish_color_operator ${raw palette.syntaxOp}
		set -g fish_color_escape ${raw palette.syntaxTag}
		set -g fish_color_autosuggestion ${raw palette.textHelper}

		set -g fish_pager_color_progress ${raw palette.textHelper}
		set -g fish_pager_color_prefix ${raw palette.syntaxAttribute}
		set -g fish_pager_color_completion ${raw palette.textPrimary}
		set -g fish_pager_color_description ${raw palette.textHelper}
		set -g fish_pager_color_selected_background --background=${raw palette.layer01}
		set -g fish_pager_color_selected_prefix ${raw palette.syntaxAttribute}
		set -g fish_pager_color_selected_completion ${raw palette.textPrimary}

		bind \co 'commandline -i (fzf)'

		set fish_cursor_default  block
		set fish_cursor_insert   line
		set fish_cursor_replace  underscore
		set fish_cursor_visual   block
		'';
	};
}
