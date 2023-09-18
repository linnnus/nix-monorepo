# This module sets up cloudflare-dyndns for <linus.onl>.

{ lib, ... }:

let

in
{
  my.secrets.cloudflare-ddns = {
    source = ./secrets.env;
    dest = "/run/keys/cloudflare-ddns.env";
  };

  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile =  "/run/keys/cloudflare-ddns.env";
    proxied = true;
    domains = [ "linus.onl" ];
  };

  # Override the systemd service generated by `services.cloudflare-dyndns` to wait for key to be decrypted.
  systemd.services.cloudflare-dyndns.after = [ "cloudflare-ddns-key.service" ];
}