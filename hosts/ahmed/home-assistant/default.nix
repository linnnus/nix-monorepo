# This module sets up home assistant for the apartment.
{config, ...}: let
  subdomain = "ha";
in {
  services.home-assistant = {
    enable = true;

    config = {
      http = {
        # Instruct HA that it will be running behind NGINX proxy.
        use_x_forwarded_for = true;
        trusted_proxies = "127.0.0.1";
      };
    };
  };

  services.nginx.virtualHosts."${subdomain}.${config.linus.local-dns.domain}" = {
    # https://community.home-assistant.io/t/reverse-proxy-using-nginx/196954
    extraConfig = ''
      proxy_buffering off;

      location / {
          proxy_pass http://127.0.0.1:8123;
          proxy_set_header Host $host;
          proxy_redirect http:// https://;
          proxy_http_version 1.1;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
      }
    '';
  };

  linus.local-dns.subdomains = [subdomain];
}
