{
  config,
  pkgs,
  inputs,
  lib,
  hostName,
  globals,
  ...
}: let
  dummyBg = pkgs.runCommand "dummy-bg.png" {} ''
    ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:"#262626" $out
  '';
in {
  stylix = {
    enable = true;
    image = dummyBg;

    base16Scheme = ../../themes + "/${globals.themeName}.yaml";


    cursor = {
      name = "GoogleDot-Blue";
      package = pkgs.google-cursor;
      size = if hostName == "surface" then 10 else 12;
    };

    fonts = {
      sansSerif = {
        name = "IBM Plex Sans";
        package = pkgs.ibm-plex;
      };
      serif = {
        name = "IBM Plex Serif";
        package = pkgs.ibm-plex;
      };
      monospace = {
        name = "BlexMono Nerd Font";
        package = pkgs.nerd-fonts.blex-mono;
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      sizes = {
        applications = 11;
        terminal = 11;
        desktop = 11;
        popups = 11;
      };
    };

    polarity = "dark";
  };
}