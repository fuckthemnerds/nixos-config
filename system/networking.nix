{ ... }:

{
	# ── NETWORKING & SECURITY ─────────────────────────────────────────────────────
	networking.networkmanager.enable = true;
	networking.stevenblack.enable = true; # Standard ads/malware blocklist

	# --- Boot Optimization ---
	systemd.services.NetworkManager-wait-online.enable = false;

	# --- DNS & Encryption (Cloudflare DoT) ---
	services.resolved = {
		enable = true;
		settings = {
			Resolve = {
				DNSSEC = "true";
				Domains = [ "~." ];
				FallbackDNS = [ "1.1.1.1#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com" ];
				DNSOverTLS = "true";
			};
		};
	};
}
