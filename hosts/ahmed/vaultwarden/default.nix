# This module sets up a password manager. It is only available locally.
{config, ...}: {
  services.vaultwarden = {
    enable = true;

    config = {
      # The domain must match the address from where you access the server It's
      # recommended to configure this value, otherwise certain functionality
      # might not work, like attachment downloads, email links and U2F.
      #
      # For U2F to work, the server must use HTTPS, you can use Let's Encrypt
      # for free certs To use HTTPS, the recommended way is to put Vaultwarden
      # behind a reverse proxy
      #
      # See: https://github.com/dani-garcia/vaultwarden/wiki/Enabling-HTTPS
      # See: https://github.com/dani-garcia/vaultwarden/wiki/Proxy-examples
      DOMAIN = "https://vaultwarden.${config.linus.local-dns.domain}";

      ROCKET_ADDRESS = "127.0.0.1"; # Behind reverse proxy.
      ROCKET_PORT = 8222;
    };
  };

  # Vaultwarden currently recommends running behind a reverse proxy
  # (nginx or similar) for TLS termination:
  #
  # > you should avoid enabling HTTPS via vaultwarden's built-in Rocket TLS support,
  # > especially if your instance is publicly accessible.
  #
  # See: https://github.com/dani-garcia/vaultwarden/wiki/Hardening-Guide#reverse-proxying
  services.nginx.virtualHosts."vaultwarden.${config.linus.local-dns.domain}" = {
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://${toString config.services.vaultwarden.config.ROCKET_ADDRESS}:${toString config.services.vaultwarden.config.ROCKET_PORT}";
    };
  };

  linus.local-dns.subdomains = ["vaultwarden"];
}
