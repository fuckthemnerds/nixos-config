{
  config,
  lib,
  pkgs,
  inputs,
  userName,
  ...
}: {
  determinate.enable = true;

  nix = {
    settings = {
      trusted-users = ["root" userName];
      allowed-users = ["@wheel"];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      cores = 0;
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  systemd = {
    settings.Manager = {
      RuntimeWatchdogSec = "30s";
      RebootWatchdogSec = "10m";
    };
    services.NetworkManager-wait-online.enable = false;
  };

  services = {
    dbus.implementation = "broker";
    journald.extraConfig = ''
      RuntimeMaxUse=64M
      Storage=persistent
      ForwardToSyslog=no
    '';
  };

  zramSwap.enable = true;
  environment.variables.FLAKE = "/home/${userName}/nixcfg";
}
