{lib, ...}: {
  # TODO ==> Make finix init

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        consoleMode = "max";
      };
      timeout = 5;
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = true;

    initrd.systemd.enable = true;

    tmp = {
      useTmpfs = true;
      tmpfsSize = lib.mkDefault "50%";
    };

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "watchdog.watchdog_thresh=30"
      "panic=10"
      "split_lock_detect=off"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
    };
  };
}
