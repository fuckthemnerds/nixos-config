{ ... }:

{
	# Bootloader setup (systemd-boot for much faster Btrfs booting)
	boot.loader.systemd-boot.enable = true;
	boot.loader.systemd-boot.configurationLimit = 10;
	boot.loader.efi.canTouchEfiVariables = true;

	# Visual Boot (Plymouth)
	boot.plymouth.enable = true;
	boot.plymouth.theme = "bgrt"; # OEM logo on black — cleanest dark boot

	# Enable systemd in initrd for parallelised early boot and robust btrfs wiping
	boot.initrd.systemd.enable = true;

	# Advanced sysctl tuning for memory and network performance
	boot.kernel.sysctl = {
		"vm.swappiness" = 10;
		"vm.vfs_cache_pressure" = 50;
		"net.core.default_qdisc" = "fq";
		"net.ipv4.tcp_congestion_control" = "bbr";
	};
}
