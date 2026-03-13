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
  services.coredns = {
    enable = true;

    config = let
      cfg = config.linus.local-dns;
      generateAuthoritativeServer = ip: ''
        ${cfg.domain} {
          bind ${ip}
          hosts {
            ${lib.concatMapStringsSep "\n" (subdomain: "${ip} ${subdomain}.${cfg.domain}") cfg.subdomains}
          }
        }
      '';
    in ''
      ${generateAuthoritativeServer metadata.hosts.ahmed.networks.rumpenettet.v4}
      ${generateAuthoritativeServer metadata.hosts.ahmed.networks.rumpevpn.v4}

      # Forward all other traffic to public recursors.
      . {
        forward . 8.8.8.8 9.9.9.9
        log
      }
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
