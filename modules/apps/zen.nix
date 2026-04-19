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
        set update.lastchecktime 1776613539174
        set configversion 2.0

        colourscheme mytheme
        set theme mytheme

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
      '';

      xdg.configFile."tridactyl/themes/mytheme/mythem.css".text = with config.lib.stylix.colors; ''
        :root.TridactylThemeMytheme {
          --tridactyl-font-family: "${config.stylix.fonts.monospace.name}", monospace;
          --tridactyl-font-size: 13pt;
          --tridactyl-small-font-size: 11pt;

          --tridactyl-bg: #${base00};
          --tridactyl-fg: #${base05};
          --tridactyl-border-radius: 4px;

          --tridactyl-cmdl-bg: #${base01};
          --tridactyl-cmdl-fg: #${base05};
          --tridactyl-cmdl-font-size: 1.6rem;
          --tridactyl-cmdl-border: 1px solid #${base03};

          --tridactyl-status-font-family: "${config.stylix.fonts.monospace.name}", monospace;
          --tridactyl-status-font-size: 12px;
          --tridactyl-status-bg: #${base01};
          --tridactyl-status-fg: #${base05};
          --tridactyl-status-border: 1px solid #${base03};
          --tridactyl-status-border-radius: 4px;

          --tridactyl-hintspan-font-size: var(--tridactyl-small-font-size);
          --tridactyl-hintspan-font-weight: 700;
          --tridactyl-hintspan-fg: #${base01};
          --tridactyl-hintspan-bg: #${base0D};
          --tridactyl-hintspan-border-width: 0px;
          --tridactyl-hintspan-border-style: solid;
          --tridactyl-hintspan-border-color: transparent;

          --tridactyl-hint-active-fg: #${base01};
          --tridactyl-hint-active-bg: #${base0E};
          --tridactyl-hint-active-outline: 1px solid #${base0E};

          --tridactyl-cmplt-option-height: 1.8em;
          --tridactyl-of-bg: #${base01};
          --tridactyl-of-fg: #${base05};

          --tridactyl-header-font-size: 14px;
          --tridactyl-header-font-weight: 700;
          --tridactyl-header-main-bg: #${base00};
          --tridactyl-header-main-fg: #${base05};
          --tridactyl-header-second-bg: #${base01};
          --tridactyl-header-second-fg: #${base0D};
          --tridactyl-header-third-bg: #${base01};

          --tridactyl-highlight-box-font-weight: 700;
          --tridactyl-highlight-box-bg: #${base01};
          --tridactyl-highlight-box-fg: #${base05};
        }

        :root #command-line-holder {
          order: 1 !important;
        }

        :root #completions {
          order: 2 !important;
        }

        :root .TridactylStatusIndicator {
          font-family: var(--tridactyl-font-family) !important;
        }
      '';
    };
  };
}
