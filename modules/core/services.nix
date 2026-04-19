{ config, pkgs, ... }:

{
	imports = [
		./networking.nix
	];

	services = {
		dbus.implementation = "broker";
		earlyoom = {
			enable = true;
			enableNotifications = true;
		};

		ananicy = {
			enable = true;
			package = pkgs.ananicy-cpp;
			rulesProvider = pkgs.ananicy-rules-cachyos;
		};

		auto-cpufreq.enable = (config.networking.hostName == "surface");

		journald.extraConfig = ''
			RuntimeMaxUse=64M
			Storage=persistent
			ForwardToSyslog=no
		'';

		fstrim = {
			enable = true;
			interval = "weekly";
		};

		btrfs.autoScrub = {
			enable = true;
			interval = "monthly";
			fileSystems = [ "/" ];
		};

		displayManager.ly = {
			enable = true;
			x11Support = false;
		};

		fail2ban.enable = true;
	};

	security = {
		auditd.enable = true;
		pam = {
			services.hyprlock = {};
			loginLimits = [
				{ domain = "*"; item = "maxlogins"; type = "hard"; value = "3"; }
			];
		};
	};
}