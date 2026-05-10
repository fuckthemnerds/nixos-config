{
  config,
  pkgs,
  lib,
  ...
}: {
  services = {
    earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    auto-cpufreq.enable = lib.mkDefault false;
    tlp.enable = true;
    thermald.enable = true;
    udisks2.enable = true;

    fstrim = {
      enable = true;
      interval = "weekly";
    };

    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };

    displayManager.ly = {
      enable = true;
      x11Support = false;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };

  boot.tmp = {
    useTmpfs = true;
    size = lib.mkDefault "50%";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam = {
      services.hyprlock = {};
      loginLimits = [
        {
          domain = "*";
          item = "maxlogins";
          type = "hard";
          value = "3";
        }
      ];
    };
  };
}