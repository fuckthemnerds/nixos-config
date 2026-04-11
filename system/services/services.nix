{ config, pkgs, ... }:

{
	imports = [
		./networking.nix
	];

	services.dbus.implementation = "broker";
	services.earlyoom.enable = true;
	services.earlyoom.enableNotifications = true;

	zramSwap.enable = true;

	services.ananicy = {
		enable = true;
		package = pkgs.ananicy-cpp;
		rulesProvider = pkgs.ananicy-rules-cachyos;
	};

	services.auto-cpufreq.enable = (config.networking.hostName == "surface");
	services.journald.extraConfig = ''
		RuntimeMaxUse=64M
		Storage=persistent
		ForwardToSyslog=no
	'';

	services.fstrim = {
		enable = true;
		interval = "weekly";
	};

	services.btrfs.autoScrub = {
		enable = true;
		interval = "monthly";
		fileSystems = [ "/" ];
	};
	
	services.fail2ban.enable = true;

	security.auditd.enable = true;

	security.pam.services.hyprlock = {};

	security.pam.loginLimits = [
		{ domain = "*"; item = "maxlogins"; type = "hard"; value = "3"; }
	];
}