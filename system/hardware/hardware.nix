{ config, pkgs, hostName, ... }:

{
	services.power-profiles-daemon.enable = true;
	hardware.enableRedistributableFirmware = true;
	services.fwupd.enable = true; # Automatically handle firmware updates

	hardware.graphics = {
		enable = true;
		enable32Bit = true;
	};

	# Bluetooth (experimental percentage reporting enabled)
	hardware.bluetooth = {
		enable = true;
		powerOnBoot = (hostName == "surface");
		settings = { General = { Experimental = true; }; };
	};
}
