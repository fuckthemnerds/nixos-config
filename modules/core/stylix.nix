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
      
      #TODO => Change cursor
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
        applications = 12;
        terminal = 12;
        desktop = 12;
        popups = 12;
      };
    };

    polarity = "dark";
  };
}
