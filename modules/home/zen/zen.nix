{
  config,
  lib,
  pkgs,
  globals,
  inputs,
  ...
}: let
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
    # TODO ==> Check if it even works
    extraPrefs = (builtins.readFile ./user.js) + "\n" + customPrefs;
    extraPolicies = {
      DisableTelemetry = true;
      ExtensionSettings = builtins.listToAttrs extensions;
    };
  };
in {
  options.apps.zen.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      home.packages = [zenPkg];

      home.file.".zen/default/chrome/userChrome.css".text = ''
        * {
          border-radius: 0 !important;
        }
      '';
    };
  };
}
