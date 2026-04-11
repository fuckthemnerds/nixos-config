{ ... }:

{
	networking.networkmanager.enable = true;
	networking.stevenblack.enable = true;

	networking.firewall = {
		enable = true;
		allowPing = false;
		rejectPackets = true;

		# Open only what is strictly needed
		# SSH — enable only if remote access is required
		# allowedTCPPorts = [ 22 ];

		# Required for Wayland screen sharing via PipeWire
		allowedUDPPortRanges = [
			{ from = 49152; to = 65534; }
		];
	};

	systemd.services.NetworkManager-wait-online.enable = false;

	services.resolved = {
		enable = true;
		dnssec = "true";
		domains = [ "~." ];
		fallbackDns = [
			"1.1.1.1#cloudflare-dns.com"
			"1.0.0.1#cloudflare-dns.com"
			"9.9.9.9#dns.quad9.net"
		];
		dnsovertls = "true";
	};
}
