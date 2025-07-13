{metadata, ...}: let
  domain = "notifications.${metadata.domains.personal}";

  # Enable HTTPS stuff.
  useACME = true;
in {
  config = {
    # Start the proxied service.
    services.push-notification-api = {
      enable = true;
    };

    # Register domain name.
    services.cloudflare-dyndns.domains = [domain];

    # Use NGINX as reverse proxy.
    services.nginx.virtualHosts.${domain} = {
      enableACME = useACME;
      forceSSL = useACME;
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://unix:/run/push-notification-api.sock";
      };
    };
  };
}
