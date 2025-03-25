# This module creates a local DNS server which provides "split horizon DNS".
#
# It only serves devices on the LAN (see `services.dnscache.clientIps`) and for
# those, it claims to have authority over the domain set in `config.linus.local-dns.domain`.
#
# See: https://www.fefe.de/djbdns/split-horizon
{
  config,
  metadata,
  lib,
  ...
}: {
  services.dnscache = {
    enable = true;
    clientIps = [
      "192.168" # LAN
      "127.0.0.1" # Local connections
    ];

    domainServers = {
      # Forward any requests to the split domain to our local, authoritative name server.
      ${config.linus.local-dns.domain} = ["127.0.0.1"];
    };
  };

  # Authoritative name server which claims ownership of the split domain.
  services.tinydns = {
    enable = true;

    # We will only listen for internal queries from the DNS cache.
    ip = "127.0.0.1";

    # Here we publish all the services we want.
    data = let
      subdomainToARecord = subdomain: "=${subdomain}.${config.linus.local-dns.domain}:${metadata.hosts.ahmed.ipv4Address}";
      ARecords = lib.concatMapStringsSep "\n" subdomainToARecord config.linus.local-dns.subdomains;
    in ''
      # We are authoritative over ${config.linus.local-dns.domain}.
      # Here we simply identify as localhost, as only the local dnscache instance will ever see this (I think).
      .${config.linus.local-dns.domain}:127.0.0.1:a
      # Next, we link all the subdomains to our LAN IP.
      ${ARecords}
    '';
  };

  # Allow other devices on LAN to interact with us. In the router's DHCP
  # settings, I have set ahmed's IP as the primary DNS server. This will make
  # all clients (which respect DNS from DHCP) use ahmed if he's online.
  #
  # Notably, the NAT on the router does not route external trafic here; we are
  # a non-authoritative DNS resolver, so we don't want to service the global
  # internet.
  networking.firewall = {
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };
}
