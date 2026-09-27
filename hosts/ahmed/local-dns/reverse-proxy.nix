# This contains the configuration for NGINX. Anything to do with reverse
# proxying these local sites goes in here.
{
  config,
  lib,
  metadata,
  ...
}: {
  services.nginx = {
    # Only allow access from LAN/VPN. Otherwise an intruder could just manually
    # set the Host-header to that of one of the local services.
    #
    # I don't like how far removed this security code is from where the
    # services are defined, but I guess it's not too bad since any service
    # that's part of local DNS has to register through the option
    # `linus.local-dns.subdomains`.
    virtualHosts = lib.listToAttrs (map (subdomain: {
        name = "${subdomain}.${config.linus.local-dns.domain}";
        value = {
          extraConfig = let
            # TODO: Handle IPv6.
            allowNetwork = network: "allow ${network.v4}/${toString network.v4PrefixLength};";
          in ''
            ${allowNetwork metadata.networks.ulvevpn}
            ${allowNetwork metadata.networks.ulvehulen}
            deny all;
          '';
        };
      })
      config.linus.local-dns.subdomains);
  };
}
