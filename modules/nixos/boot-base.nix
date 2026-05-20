# -----------------------------------------------------------------------------
#  MODULE: boot-base.nix
#  DESCRIPTION: Core boot settings common to all machines.
#  This module defines foundational kernel configurations, performance sysctl
#  rules, and basic initrd properties.
# -----------------------------------------------------------------------------
{
  config,
  lib,
  ...
}: {
  # Essential kernel parameters for stability, quiet boot, and security
  boot.kernelParams = [
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "watchdog.watchdog_thresh=30"
    "panic=10"
    "split_lock_detect=off"
  ];

  # Core kernel sysctl tweaks for virtual memory, networking, and kernel security
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
  };

  # Systemd in initrd for faster boot and modern stage 1 service management
  boot.initrd.systemd.enable = true;

  # EFI variables support for bootloader modifications
  boot.loader.efi.canTouchEfiVariables = true;

  # Use tmpfs for /tmp to improve disk wear and speed
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = lib.mkDefault "50%";
  };
}
