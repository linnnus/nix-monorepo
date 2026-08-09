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
      generateServer = ip: ''
        . {
          bind ${ip}

          # Point all special subdomains at our own IP address.
          hosts {
            ${lib.concatMapStringsSep "\n" (subdomain: "${ip} ${subdomain}.${cfg.domain}") cfg.subdomains}
            fallthrough
          }

          # Forward regular internet traffic to a public recursor.
          forward . 1.1.1.1 8.8.8.8
          cache 30
          log
        }
      '';
    in ''
      ${generateServer metadata.hosts.ahmed.networks.rumpenettet.v4}
      ${generateServer metadata.hosts.ahmed.networks.rumpevpn.v4}
    '';
  };

  # I am having some trouble where bind(2) is failing with EADDRNOTAVAIL [0].
  # (This was evident when running CoreDNS under strace.) This error code
  # indicates that:
  #
  # > A nonexistent interface was requested or the requested
  # > address was not local.
  #
  # The service currently depends on `network.target` [2] but that is not
  # sufficient to guarantee that all network interfaces have been brought up!
  # According to [1]:
  #
  # > `network.target` indicates that the network management stack has been
  # > started. Ordering after it has little meaning during start-up: whether any
  # > network interfaces are already configured when it is reached is not
  # > defined.
  #
  # Instead, the docs say we should rely on `network-online.target`.
  #
  # Thoguh they _do_ also say that the best solution is simply to bind to
  # `0.0.0.0`. But that is not an option for us because of how we set up the
  # split-view DNS.
  #
  # [0]: https://www.man7.org/linux/man-pages/man2/bind.2.html
  # [1]: https://systemd.io/NETWORK_ONLINE/#:~:text=whether%20any%20network%20interfaces%20are%20already%20configured%20when%20it%20is%20reached%20is%20not%20defined
  # [2]: https://github.com/NixOS/nixpkgs/blob/ee48b147c18c7de1e6ec97dc74792be42724bed1/nixos/modules/services/networking/coredns.nix#L42
  systemd.services.coredns.after = ["network-online.target"];
  systemd.services.coredns.wants = ["network-online.target"];

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
