{ ... }: {

  # ===========================================================================
  # Network Interfaces & Connectivity
  # ===========================================================================
  networking = {
    # Utilize StevenBlack's hosts file for system-wide ad and malware blocking.
    stevenblack.enable = true;

    # Disable NetworkManager in favor of the lighter, more focused iwd.
    networkmanager.enable = false;

    wireless.iwd = {
      enable = true;
      settings = {
        Network.EnableIPv6 = true;
        Settings.AutoConnect = true;
      };
    };

    # =========================================================================
    # Firewall & Security
    # =========================================================================
    firewall = {
      enable = true;
      
      # Drop ICMP echo requests (ping) to reduce visibility to automated scans.
      allowPing = false;
      
      # Reject packets instead of dropping them silently (cleaner connection resets).
      rejectPackets = true;
    };

    # Define primary nameservers (Cloudflare) for initial resolution.
    # Note: systemd-resolved (configured below) handles the actual DNS-over-TLS.
    nameservers = [
      "1.1.1.1#cloudflare-dns.com"
      "1.0.0.1#cloudflare-dns.com"
    ];
  };

  # ===========================================================================
  # Network Services
  # ===========================================================================
  services = {
    openssh.enable = true;

    resolved = {
      enable = true;
      settings.Resolve = {
        # Allow fallback to non-DNSSEC if validation fails, ensuring connectivity.
        DNSSEC = "allow-downgrade";
        
        # Route all DNS queries through resolved.
        Domains = "~.";
        
        FallbackDNS = "1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net";
        
        # Attempt DNS-over-TLS (DoT) but fall back to plaintext if unsupported by the server.
        DNSOverTLS = "opportunistic";
      };
    };
  };
}
