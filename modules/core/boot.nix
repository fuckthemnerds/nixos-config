{ ... }:

{
	boot = {
		loader = {
			systemd-boot = {
				enable = true;
				configurationLimit = 10;
				consoleMode = "max";
			};
			timeout = 5; # Ensure menu is visible
			efi.canTouchEfiVariables = true;
		};

		plymouth = {
			enable = true;
		};

		initrd.systemd.enable = true;

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