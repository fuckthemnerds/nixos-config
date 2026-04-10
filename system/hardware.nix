{ config, pkgs, hostName, ... }:

{
	# Hardware Graphics (VAAPI)
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
