{ ... }:

{
	boot.loader.systemd-boot.enable = true;

	boot.loader.efi.canTouchEfiVariables = true;

	boot.plymouth.enable = true;
	boot.plymouth.theme = "bgrt"; # OEM logo on black — cleanest dark boot

	boot.initrd.systemd.enable = true;

	systemd.watchdog.runtimeTime = "30s";
	systemd.watchdog.rebootTime = "10m";

	boot.kernelParams = [
		"watchdog.watchdog_thresh=30"
		"panic=10"
	];

	boot.kernel.sysctl = {
		"vm.swappiness" = 10;
		"vm.vfs_cache_pressure" = 50;
		"net.core.default_qdisc" = "fq";
		"net.ipv4.tcp_congestion_control" = "bbr";
	};
}