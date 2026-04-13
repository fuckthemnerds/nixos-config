{ config, lib, pkgs, userName, ... }:
let
  cfg = config.apps.fish;
in
{
  options.apps.fish.enable = lib.mkEnableOption "fish shell";

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;

    home-manager.users.${userName} = {
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

        shellAbbrs = {
          nrs   = "nh os switch";
          nrb   = "nh os boot";
          nrt   = "nh os test";
          nrh   = "nh home switch";
          nfu   = "nix flake update";
          nfc   = "nix flake check";
          cdnix = "cd /persistent/etc/nixos";
          gst   = "git status";
          gd    = "git diff";
          ga    = "git add";
          gaa   = "git add -A";
          gc    = "git commit -m";
          gca   = "git commit --amend --no-edit";
          gp    = "git push";
          gpl   = "git pull";
          gl    = "git log --oneline --graph --decorate -20";
          zo    = "zo";
        };

        shellAliases = {
          ls    = "eza --icons";
          ll    = "eza -lh --icons --grid --group-directories-first";
          la    = "eza -lah --icons --grid --group-directories-first";
          lt    = "eza --tree --icons";
          y     = "yazi";
          sudo  = "sudo --preserve-env=PATH,EDITOR,VISUAL env";
        };

        interactiveShellInit = ''
          fastfetch

          function zo
            if test (count $argv) -gt 0
              zathura $argv & disown; and exit
            else
              set -l file (fzf)
              if test -n "$file"
                zathura "$file" & disown; and exit
              end
            end
          end
          set -g fish_greeting
          fish_vi_key_bindings
          set -g tide_left_prompt_items pwd git newline character
          set -g tide_right_prompt_items status cmd_duration jobs direnv
          set -g tide_cmd_duration_threshold 3000
          set -g tide_cmd_duration_decimals 0
          bind \co 'commandline -i (fzf)'
          set fish_cursor_default  block
          set fish_cursor_insert   line
          set fish_cursor_replace  underscore
          set fish_cursor_visual   block
        '';
      };
    };
  };
}