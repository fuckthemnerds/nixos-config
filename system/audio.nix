{ ... }:

{
	# Realtime scheduling for audio
	security.rtkit.enable = true;

	# Core Audio Routing (Pipewire)
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
	};
}
