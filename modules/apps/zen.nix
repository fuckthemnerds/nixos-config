{ config, lib, pkgs, globals, inputs, ... }:

let
  cfg = config.apps.zen;

  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  extensions = [
    (extension "ublock-origin" "uBlock0@raymondhill.net")
    (extension "sponsorblock" "sponsorBlocker@ajay.app")
    (extension "keepassxc-browser" "keepassxc-browser@keepassxc.org")
    (extension "tridactyl-vim" "tridactyl.vim@cmcaine.co.uk")
  ];

  customPrefs = ''
    user_pref("privacy.clearOnShutdown.cookies", false);
    user_pref("privacy.clearOnShutdown.sessions", false);
    user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
    user_pref("network.cookie.lifetimePolicy", 0);
    user_pref("browser.startup.page", 3);
  '';

  zenPkg = pkgs.wrapFirefox inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped {
    extraPrefs = (builtins.readFile ../helpers/user.js) + "\n" + customPrefs;
    extraPolicies = {
      DisableTelemetry = true;
      ExtensionSettings = builtins.listToAttrs extensions;
    };
  };

in
{
  options.apps.zen.enable = lib.mkEnableOption "zen";

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      home.packages = [ zenPkg ];

      xdg.configFile."tridactyl/tridactylrc".text = ''
        bind <Space> fillcmdline cmdline

        bind H back
        bind L forward
        bind J tabnext
        bind K tabprev
        bind gT tabprev
        bind gt tabnext

        set searchengine duckduckgo
        bind / fillcmdline find
        bind n findnext
        bind N findprev

        set hintfiltermode vimperator
        set hintchars 5432167890
        bind f hint

        set smoothscroll true
        set newtab about:blank
        set autocontain block
        set editorcmd nvim
        set editor --cmd "set columns=120 lines=40"

        colourscheme mytheme
      '';

      xdg.configFile."tridactyl/themes/mytheme/mythem.css".text = with config.lib.stylix.colors; ''
        :root {
          --tridactyl-bg: #${base00};
          --tridactyl-fg: #${base05};
          --tridactyl-cmdl-bg: #${base01};
          --tridactyl-cmdl-fg: #${base05};

          --tridactyl-header-first-bg: #${base02};
          --tridactyl-header-first-fg: #${base07};
          --tridactyl-header-second-bg: #${base01};
          --tridactyl-header-second-fg: #${base05};

          --tridactyl-cmplt-bg: #${base00};
          --tridactyl-cmplt-fg: #${base05};
          --tridactyl-cmplt-border: #${base03};
          --tridactyl-cmplt-scrollbar-color: #${base04};

          --tridactyl-url-fg: #${base0D};
          --tridactyl-url-bg: #${base00};

          --tridactyl-action-bg: #${base01};
          --tridactyl-action-fg: #${base05};

          --tridactyl-highlight-bg: #${base0A};
          --tridactyl-highlight-fg: #${base00};

          --tridactyl-error-fg: #${base08};
          --tridactyl-warning-fg: #${base0A};
          --tridactyl-success-fg: #${base0B};
          --tridactyl-info-fg: #${base0C};

          --tridactyl-special-fg: #${base0E};
          --tridactyl-accent: #${base0D};
        }
      '';
    };
  };
}
