{metadata, ...}: {
  services.dnscache = {
    enable = true;
    clientIps = [
      "192.168" # LAN
      "127.0.0.1" # Local connections
    ];

    domainServers = {
      "internal" = ["127.0.0.1"];
    };
  };

  services.tinydns = {
    enable = true;

    # We will only listen for internal queries from the DNS cache.
    ip = "127.0.0.1";

    data = ''
      .internal:127.0.0.1:a
      =ahmed.internal:${metadata.hosts.ahmed.ipAddress}
      =muhammed.internal:${metadata.hosts.muhammed.ipAddress}
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };
}
