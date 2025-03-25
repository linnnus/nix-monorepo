# This module adds some extra configuration useful when running behid a Cloudflare Proxy.
# Mainly, it blocks all incomming conncections on relevant ports that aren't
# coming from an official CloudFlare domain.
{
  config,
  lib,
  pkgs,
  ...
}: let
  # TODO: What happens when these get out of date??? Huh??? You little pissbaby
  fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
  cfipv4 = fileToList (pkgs.fetchurl {
    url = "https://www.cloudflare.com/ips-v4";
    hash = "sha256-8Cxtg7wBqwroV3Fg4DbXAMdFU1m84FTfiE5dfZ5Onns=";
  });
  cfipv6 = fileToList (pkgs.fetchurl {
    url = "https://www.cloudflare.com/ips-v6";
    hash = "sha256-np054+g7rQDE3sr9U8Y/piAp89ldto3pN9K+KCNMoKk=";
  });

  # Allow local IP addresses.
  # See: https://en.wikipedia.org/wiki/Reserved_IP_addresses
  IPv4Whitelist = [
    "100.64.0.0/10 "
    "10.0.0.0/8"
    "127.0.0.0/8"
    "172.16.0.0/12"
    "192.0.0.0/24"
    "192.168.0.0/16"
    "198.18.0.0/15"
  ];
  IPv6Whitelist = [
    "64:ff9b:1::/48 "
    "fc00::/7"
  ];
in {
  config = {
    # Teach NGINX how to extract the proxied IP from proxied requests.
    #
    # See: https://nixos.wiki/wiki/Nginx#Using_realIP_when_behind_CloudFlare_or_other_CDN
    services.nginx.commonHttpConfig = let
      realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
    in ''
      ${realIpsFromList cfipv4}
      ${realIpsFromList cfipv6}
      real_ip_header CF-Connecting-IP;
    '';

    # Block non-Cloudflare IP addresses.
    networking.firewall = let
      chain = "cloudflare-whitelist";
    in {
      extraCommands = let
        allow-interface = lib.strings.concatMapStringsSep "\n" (i: ''ip46tables --append ${chain} --in-interface ${i} --jump RETURN'');
        allow-ip = cmd: lib.strings.concatMapStringsSep "\n" (r: ''${cmd} --append ${chain} --source ${r} --jump RETURN'');
      in ''
        # Flush the old firewall rules. This behavior mirrors the default firewall service.
        # See: https://github.com/NixOS/nixpkgs/blob/ac911bf685eecc17c2df5b21bdf32678b9f88c92/nixos/modules/services/networking/firewall-iptables.nix#L59-L66
        ip46tables --delete INPUT --protocol tcp --destination-port 80  --syn --jump ${chain} 2>/dev/null || true
        ip46tables --delete INPUT --protocol tcp --destination-port 443 --syn --jump ${chain} 2>/dev/null || true
        ip46tables --flush ${chain} || true
        ip46tables --delete-chain ${chain} || true

        # Create a chain that only allows whitelisted IPs through.
        ip46tables --new-chain ${chain}

        # Allow trusted interfaces through.
        ${allow-interface config.networking.firewall.trustedInterfaces}

        # Allow local whitelisted IPs through
        ${allow-ip "iptables" IPv4Whitelist}
        ${allow-ip "ip6tables" IPv6Whitelist}

        # Allow Cloudflare's IP ranges through.
        ${allow-ip "iptables" cfipv4}
        ${allow-ip "ip6tables" cfipv6}

        # Everything else is dropped.
        #
        # TODO: I would like to use `nixos-fw-log-refuse` here, but I keep
        #       running into weird issues when reloading the firewall.
        #       Something about the table not being deleted properly.
        ip46tables --append ${chain} --jump DROP

        # Inject our chain as the first check in INPUT (before nixos-fw).
        # We want to capture any new incomming TCP connections.
        ip46tables --insert INPUT 1 --protocol tcp --destination-port 80 --syn --jump ${chain}
        ip46tables --insert INPUT 1 --protocol tcp --destination-port 443 --syn --jump ${chain}
      '';
      extraStopCommands = ''
        # Clean up added rulesets (${chain}). This mirrors the behavior of the
        # default firewall at the time of writing.
        #
        # See: https://github.com/NixOS/nixpkgs/blob/ac911bf685eecc17c2df5b21bdf32678b9f88c92/nixos/modules/services/networking/firewall-iptables.nix#L218-L219
        ip46tables --delete INPUT --protocol tcp --destination-port 80  --syn --jump ${chain} 2>/dev/null || true
        ip46tables --delete INPUT --protocol tcp --destination-port 443 --syn --jump ${chain} 2>/dev/null || true
      '';
    };
  };
}
