{
  config,
  lib,
  pkgs,
  globals,
  inputs,
  myLib,
  ...
}: let
  cfg = config.apps.helium;
  helium-pkg = inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  # ===========================================================================
  # Options
  # ===========================================================================
  options.apps.helium = {
    enable = myLib.mkEnableOpt "Helium browser";
    package = lib.mkOption {
      type = lib.types.package;
      default = helium-pkg;
      description = "The Helium browser package derivation.";
    };
  };

  config = myLib.mkIfEnabled cfg.enable (myLib.mkHome globals.userName {
    home.packages = [cfg.package];
  });
}
