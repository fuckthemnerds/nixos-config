{
  config,
  pkgs,
  lib,
  ...
}: {
  services = {
    dbus.implementation = "broker";
    journald.extraConfig = ''
      RuntimeMaxUse=64M
      Storage=persistent
      ForwardToSyslog=no
    '';

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
      enable = lib.mkDefault true;
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

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
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