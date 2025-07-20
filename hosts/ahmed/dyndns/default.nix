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

  # We have to authenticate the Cloudflare's DDNS service with an API key. This
  # file should contain an API token which should have permission to edit the
  # DNS records all the domains used in hosts/ahmed/.
  #
  # WARNING: This file should NOT be shared among different machines. The token
  # should ONLY have permission to edit the domains associated with Ahmed.
  # Anything else would be a violation of the principle of least privelege. A
  # restructure would be needed in such a case.
  #
  # The token belongs to your personal account [0]. See the CloudFlare documentation [1].
  #
  # [0]: https://dash.cloudflare.com/profile/api-tokens
  # [1]: https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
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
