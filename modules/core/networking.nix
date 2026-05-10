{ ... }: {
  networking = {
    stevenblack.enable = true;

    networkmanager.enable = false;

    wireless.iwd = {
      enable = true;
      settings = {
        Network.EnableIPv6 = true;
        Settings.AutoConnect = true;
      };
    };

    firewall = {
      enable = true;
      allowPing = false;
      rejectPackets = true;
    };

    nameservers = [
      "1.1.1.1#cloudflare-dns.com"
      "1.0.0.1#cloudflare-dns.com"
    ];
  };

  services.openssh.enable = true;

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = ["~."];
    fallbackDns = [
      "1.1.1.1#cloudflare-dns.com"
      "1.0.0.1#cloudflare-dns.com"
      "9.9.9.9#dns.quad9.net"
    ];
    dnsOverTls = "opportunistic";
  };
}