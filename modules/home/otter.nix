{
  config,
  lib,
  pkgs,
  globals,
  inputs,
  myLib,
  ...
}: let
  cfg = config.apps.otter;
  otter-pkg = pkgs.rustPlatform.buildRustPackage {
    pname = "otter-launcher";
    version = "unstable";
    src = inputs.otter-launcher;
    cargoLock.lockFile = "${inputs.otter-launcher}/Cargo.lock";
    meta = {
      description = "A hackable cli/tui launcher for keyboard-centric WM users";
      mainProgram = "otter";
    };
  };
in {
  options.apps.otter = {
    enable = myLib.mkEnableOpt "otter-launcher";
    package = lib.mkOption {
      type = lib.types.package;
      default = otter-pkg;
      description = "The otter-launcher package derivation.";
    };
  };

  config = myLib.mkIfEnabled cfg.enable (lib.mkMerge [
    (myLib.mkHome globals.userName {
      home.packages = [otter-pkg];
    })
    {
      environment.etc."otter-launcher/config.toml".text = ''
        [general]
        default_module = "app"
        empty_module = "a"
        exec_cmd = "sh -c"
        vi_mode = true
        esc_to_abort = true
        cheatsheet_entry = "?"
      cheatsheet_viewer = "less -R; clear"
      clear_screen_after_execution = false
      loop_mode = false
      external_editor = ""

      [interface]
      header = """
       \u001B[34;1m  >\u001B[0m $USER@$(echo $HOSTNAME)                \u001B[31m\u001B[0m $(cat /proc/loadavg | cut -d ' ' -f 1)  \u001B[33m\u001B[0m $(free -h | awk 'FNR == 2 {print $3}' | sed 's/i//')
          \u001B[34;1m>\u001B[0;1m """
      header_cmd = ""
      header_cmd_trimmed_lines = 0
      header_concatenate = false
      list_prefix = "      "
      selection_prefix = "    \u001B[31;1m> "
      place_holder = "type and search"
      default_module_message = "      \u001B[33msearch\u001B[0m the internet"
      empty_module_message = ""
      suggestion_mode = "list"
      suggestion_lines = 12
      indicator_with_arg_module = "\u001B[31m^\u001B[0m "
      indicator_no_arg_module = "\u001B[31m$\u001B[0m "
      prefix_padding = 3
      prefix_color = "\u001B[33m"
      description_color = "\u001B[39m"
      place_holder_color = "\u001B[30m"
      hint_color = "\u001B[30m"
      move_right = 0
      move_up = 0

      [[modules]]
      description = "search with duckduckgo"
      prefix = "ddg"
      cmd = "setsid -f xdg-open 'https://duckduckgo.com/?q={}'"
      with_argument = true
      url_encode = true

      [[modules]]
      description = "kill a runing app"
      prefix = "k"
      cmd = 'ps -u "$USER" -o comm= | sort -u | ${pkgs.fuzzel}/bin/fuzzel -d | xargs -r pkill -9'
      with_argument = false
      url_encode = false

      [[modules]]
      description = "launch apps with fuzzel"
      prefix = "a"
      cmd = "${pkgs.fuzzel}/bin/fuzzel"
      with_argument = false

      [[modules]]
      description = "manage clipboard with cliphist"
      prefix = "cl"
      cmd = "${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel -d | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"
      with_argument = false

      [[modules]]
      description = "search nixos packages"
      prefix = "np"
      cmd = "setsid -f xdg-open 'https://search.nixos.org/packages?channel=unstable&query={}'"
      with_argument = true
      url_encode = true

      [[modules]]
      description = "search nixos options"
      prefix = "no"
      cmd = "setsid -f xdg-open 'https://search.nixos.org/options?channel=unstable&query={}'"
      with_argument = true
      url_encode = true

      [[modules]]
      description = "reboot system"
      prefix = "reboot"
      cmd = "systemctl reboot"
      with_argument = false

      [[modules]]
      description = "shutdown system"
      prefix = "shutdown"
      cmd = "systemctl poweroff"
      with_argument = false

      [[modules]]
      description = "suspend system"
      prefix = "suspend"
      cmd = "systemctl suspend"
      with_argument = false

      [[modules]]
      description = "hibernate system"
      prefix = "hibernate"
      cmd = "systemctl hibernate"
      with_argument = false

      [[modules]]
      description = "logout"
      prefix = "logout"
      cmd = "session=`loginctl session-status | head -n 1 | awk '{print $1}'`; loginctl terminate-session $session"
      with_argument = false

      [[modules]]
      description = "run command in terminal"
      prefix = "s"
      cmd = "${pkgs.foot}/bin/foot -e {}"
      with_argument = true

      [[modules]]
      description = "search archwiki"
      prefix = "w"
      cmd = "setsid -f xdg-open 'https://wiki.archlinux.org/index.php?search={}'"
      with_argument = true
      url_encode = true

      [[modules]]
      description = "merriam-webster dictionary"
      prefix = "mw"
      cmd = "setsid -f xdg-open 'https://www.merriam-webster.com/dictionary/{}'"
      with_argument = true
      url_encode = true
      '';
    }
  ]);
}
