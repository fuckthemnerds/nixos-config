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
  ];

  customPrefs = ''
    user_pref("privacy.clearOnShutdown.cookies", false);
    user_pref("privacy.clearOnShutdown.sessions", false);
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
    };
  };
}
