{ config, pkgs, ... }:

{
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

		pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
			wireplumber.enable = true;
		};

	};

	boot.tmp = {
		useTmpfs = true;
		tmpfsSize = if (config.networking.hostName == "surface") then "2G" else "50%";
	};

	hardware.bluetooth = {
		enable = true;
		powerOnBoot = true;
		settings.General.Experimental = true;
	};

	security = {
		rtkit.enable = true;
		polkit.enable = true;
		pam = {
			services.hyprlock = {};
			loginLimits = [
				{ domain = "*"; item = "maxlogins"; type = "hard"; value = "3"; }
			];
		};
	};
}