{
  config,
  lib,
  ...
}: {
  # ===========================================================================
  #  1. Kernel Parameters
  # ===========================================================================
  boot.kernelParams = [
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "watchdog.watchdog_thresh=30"
    "panic=10"
    "split_lock_detect=off"
  ];

  # ===========================================================================
  #  2. Kernel Sysctl
  # ===========================================================================
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
  };

  # ===========================================================================
  #  3. Initrd & Bootloader
  # ===========================================================================
  # Systemd in initrd for faster boot and modern stage 1 service management
  boot.initrd.systemd.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;

  # ===========================================================================
  #  4. Temporary Filesystem
  # ===========================================================================
  # Use tmpfs for /tmp to improve disk wear and speed
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = lib.mkDefault "50%";
  };
}
