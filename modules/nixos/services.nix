#############################################################
#
#  Services - System-wide core services and hardware options
#
#############################################################
{
  config,
  pkgs,
  lib,
  ...
}: {
  services = {
    # Lightweight alternative to dbus-daemon implementing the D-Bus Specification
    dbus.implementation = "broker";

    # Systemd journald logging constraints
    journald.extraConfig = ''
      RuntimeMaxUse=64M
      Storage=persistent
      ForwardToSyslog=no
    '';

    # Out-of-memory daemon to kill heavy processes before kernel panic
    earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    # Auto-adjust process niceness based on type/focus
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    # CPU governor profiles
    auto-cpufreq.enable = lib.mkDefault false;
    tlp.enable = true;
    thermald.enable = true;

    # Removable storage drive auto-mount daemon
    udisks2.enable = true;

    # Weekly SSD storage TRIM tasks
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # Monthly Btrfs scrubbing process to verify block integrity
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };

    # TUI display manager/greeter
    displayManager.ly = {
      enable = lib.mkDefault true;
      x11Support = false;
    };

    # Modern Linux audio daemon
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };

  hardware = {
    # System Bluetooth daemon settings
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };

    # Hardware accelerated graphics drivers
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
