{
  config,
  pkgs,
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

  boot.kernelParams = ["acpi_osi=Linux" "pci=noaer"];
  boot.kernelPackages = pkgs.linuxPackages_zen;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:1:0:0";
  };
}
