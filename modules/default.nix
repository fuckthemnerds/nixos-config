{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./apps/ai.nix
    ./apps/btop.nix
    ./apps/cliphist.nix
    ./apps/default.nix
    ./apps/fastfetch.nix
    ./apps/fish.nix
    ./apps/foot.nix
    ./apps/fuzzel.nix
    ./apps/git.nix
    ./apps/gui-apps.nix
    ./apps/hypridle.nix
    ./apps/hyprlock.nix
    ./apps/keepassxc.nix
    ./apps/localsend.nix
    ./apps/mako.nix
    ./apps/modern-cli.nix
    ./apps/multimedia.nix
    ./apps/niri.nix
    ./apps/nvim.nix
    ./apps/rclone.nix
    ./apps/waybar.nix
    ./apps/yazi.nix
    ./apps/zathura.nix
    ./apps/zen.nix
    ./apps/zoxide.nix

    ./core/boot.nix
    ./core/core.nix
    ./core/system.nix
    ./core/impermanence.nix
    ./core/kanata.nix
    ./core/networking.nix
    ./core/packages.nix
    ./core/services.nix
    ./core/sops.nix
    ./core/stylix.nix
    ./core/users.nix

    ./helpers/niri-enhancements.nix
  ];
}
