{
  config,
  pkgs,
  lib,
  ...
}: {

  # ===========================================================================
  # System Messaging & Diagnostic Logging
  # ===========================================================================
  services = {
    # Utilize 'dbus-broker' for superior performance, reliable resource limits,
    # and direct kernel-based IPC handling compared to standard dbus-daemon.
    dbus.implementation = "broker";

    # Restrain journald disk log write sizes to protect flash SSD lifespans.
    journald.extraConfig = ''
      RuntimeMaxUse=64M
      Storage=persistent
      ForwardToSyslog=no
    '';

    # =========================================================================
    # Resource & Power Management
    # =========================================================================
    # Out-Of-Memory (OOM) killer that preemptively drops heavy tasks under memory
    # exhaustion to maintain system responsiveness and prevent system lockups.
    earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    # Auto-adjust scheduling niceness and I/O weights of processes dynamically
    # based on rules, favoring current GUI applications and terminal shells.
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    # Dynamic CPU governor tuning tool. Disabled by default for server hosts,
    # or overridden dynamically where laptop battery life demands it.
    auto-cpufreq.enable = lib.mkDefault false;

    # TLP high-efficiency Linux power saving daemon to optimize processor sleep states.
    tlp.enable = true;

    # Intel thermal management daemon to prevent thermal throttling on heavy loads.
    thermald.enable = true;

    # =========================================================================
    # Filesystem & Storage Operations
    # =========================================================================
    # Auto-mounting service for external USB drives and media.
    udisks2.enable = true;

    # Perform periodic online block discard operations (TRIM) to preserve SSD speeds.
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # Declarative monthly background Btrfs scrubbing to verify data block checksums.
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };

    # =========================================================================
    # Display Manager & Interactive Environments
    # =========================================================================
    # Ly is a lightweight, TUI-based console display manager for Wayland/X11.
    displayManager.ly = {
      enable = lib.mkDefault true;
      x11Support = false; # Pure Wayland workspace focus
    };

    # =========================================================================
    # Audio Pipeline Configuration
    # =========================================================================
    # Pipewire audio infrastructure replacement for ALSA, PulseAudio, and JACK.
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true; # Allow legacy 32-bit audio outputs
      pulse.enable = true;
      wireplumber.enable = true; # Dynamic session manager for sound nodes
    };
  };

  # ===========================================================================
  # Hardware Device Controllers & Drivers
  # ===========================================================================
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true; # Unlock broad BLE hardware integration
    };

    graphics = {
      enable = true;
      enable32Bit = true; # Mandatory for running games under Steam/Proton
    };
  };
}
