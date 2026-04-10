{ config, pkgs, ... }:

{
	# ── SYSTEM-WIDE SERVICES ──────────────────────────────────────────────────────
	services.dbus.implementation = "broker";
	services.earlyoom.enable = true;
	services.earlyoom.enableNotifications = true;

	# --- Performance & Responsiveness ---
	zramSwap.enable = true;

	services.ananicy = {
		enable = true;
		package = pkgs.ananicy-cpp;
		rulesProvider = pkgs.ananicy-rules-cachyos;
	};

	services.auto-cpufreq.enable = (config.networking.hostName == "surface");
	services.journald.extraConfig = "RuntimeMaxUse=64M";

	# --- Maintenance (Btrfs & Storage) ---
	services.fstrim.enable = true;
	services.fstrim.interval = "weekly";

	services.btrfs.autoScrub = {
		enable = true;
		interval = "monthly";
		fileSystems = [ "/" ];
	};

	# --- Security & Wayland ---
	security.pam.services.hyprlock = {};
}
