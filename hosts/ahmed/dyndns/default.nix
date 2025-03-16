# This module sets up dynamic DNS (DDNS).
#
# Other services will register the domains to be updated via
# `services.cloudflare-dyndns.domains`.
{config, ...}: {
  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare-dyndns-api-token.path;
    proxied = true;
  };

  # We have to authenticate the Cloudflare's DDNS service with an API key.
  age.secrets.cloudflare-dyndns-api-token.file = ../../../secrets/cloudflare-ddns-token.env.age;

  # We also have to overwrite the dependencies of the DYNDNS client service to
  # make sure we are *actually* online.
  #
  # See: https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget
  systemd.services.cloudflare-dyndns = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };
}
