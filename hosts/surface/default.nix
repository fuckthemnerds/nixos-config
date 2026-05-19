{
  pkgs,
  lib,
  userName,
  ...
}: {
  apps = {
    nh.enable = true;
    steam.enable = true;
    gui-apps.enable = true;
    multimedia.enable = true;
    zathura.enable = true;
    localsend.enable = true;
    modern-cli.enable = true;
    zoxide.enable = true;
    yazi.enable = true;
    ai.enable = true;
    cliphist.enable = true;
    btop.enable = true;
    fastfetch.enable = true;
    fish.enable = true;
    foot.enable = true;
    fuzzel.enable = true;
    git.enable = true;
    hyprlock.enable = true;
    keepassxc.enable = true;
    mako.enable = true;
    niri.enable = true;
    nvim.enable = true;
    otter.enable = true;
    rclone.enable = true;
    waybar.enable = true;
    zen.enable = true;
  };

  services.auto-cpufreq.enable = true;

  zramSwap.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkForce 80;
    "vm.page-cluster" = lib.mkForce 0;
    "vm.max_map_count" = 1048576;
  };
}
