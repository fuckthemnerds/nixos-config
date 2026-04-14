{ ... }:

{
	boot = {
		loader = {
			systemd-boot = {
				enable = true;
				configurationLimit = 5;
			};
			efi.canTouchEfiVariables = true;
		};

		plymouth.enable = true;
		initrd.systemd.enable = true;

		kernelParams = [
			"watchdog.watchdog_thresh=30"
			"panic=10"
		];

		kernel.sysctl = {
			"vm.swappiness" = 10;
			"vm.vfs_cache_pressure" = 50;
			"net.core.default_qdisc" = "fq";
			"net.ipv4.tcp_congestion_control" = "bbr";
		};
	};

	systemd.settings.Manager = {
		RuntimeWatchdogSec = "30s";
		RebootWatchdogSec = "10m";
	};
}