{ config, pkgs, inputs, lib, ... }:

let
  dummyBg = pkgs.runCommand "dummy-bg.png" {} ''
    ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:"#262626" $out
  '';
in
{
  stylix = {
    enable = true;
    image = dummyBg;

    base16Scheme = {
      base00 = "161616";
      base01 = "262626";
      base02 = "393939";
      base03 = "525252";
      base04 = "6f6f6f";
      base05 = "f4f4f4";
      base06 = "c6c6c6";
      base07 = "ffffff";
      base08 = "fa4d56";
      base09 = "ff8389";
      base0A = "f1c21b";
      base0B = "42be65";
      base0C = "3ddbd9";
      base0D = "4589ff";
      base0E = "be95ff";
      base0F = "a8a8a8";
    };

    cursor = {
      name = "GoogleDot-Blue";
      package = pkgs.google-cursor;
      size = 24;
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
    };

    sizes = {
      applications = 11;
      terminal = 11;
      desktop = 11;
      popups = 11;
    };

    polarity = "dark";

    targets.waybar.enable  = false;
  };
}