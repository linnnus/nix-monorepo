# This module sets up cloudflare-dyndns for <linus.onl>.

{ lib, config, ... }:

let

in
{
  age.secrets.cloudflare-dyndns-api-token = {
    file = ../../secrets/cloudflare-ddns-token.env.age;
    # TODO: configure permissions
  };

  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare-dyndns-api-token.path;
    proxied = true;
    domains = [ "linus.onl" ];
  };
}
