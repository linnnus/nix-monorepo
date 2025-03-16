# This module configures a reverse proxy for the various services that are
# exposed to the internet.
{
  pkgs,
  config,
  lib,
  ...
}: let
  baseDomain = "internal";
  qbDomain = "qbittorrent.${baseDomain}";
  jellyfinDomain = "jellyfin.${baseDomain}";

  # The internal port where qBittorrents web UI will be served.
  qbWebUiPort = 8082;

  # Whether to use ACME/Letsencrypt to get free certificates.
  useACME = true;
in {
  services.qbittorrent = {
    openFirewall = false;
    port = qbWebUiPort;

    settings = {
      Preferences = {
        # Used in conjunction with the --webui-port flag (via services.qbittorrent.port)
        # We do NOT want qBittorrent to open the webui's port on the router,
        # since all trafic will be going through the reverse proxy anyways.
        "WebUI\\UseUPnP" = false;
      };
    };
  };

  # Use NGINX as a reverse proxy.
  services.nginx = {
    virtualHosts.${qbDomain} = {
      locations."/" = {
        proxyPass = "http://localhost:${toString qbWebUiPort}";
        recommendedProxySettings = true;
      };
    };

    virtualHosts.${jellyfinDomain} = {
      locations."/" = {
        # This is the "static port" of the HTTP web interface.
        #
        # See: https://jellyfin.org/docs/general/networking/#port-bindings
        proxyPass = "http://localhost:8096";
        recommendedProxySettings = true;
      };

      # See: https://jellyfin.org/docs/general/networking/nginx
      # See: https://nginx.org/en/docs/http/websocket.html
      locations."/socket" = {
        proxyPass = "http://localhost:8096";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
      };
    };
  };

  # See also `hosts/ahmed/dns/default.nix`.
}
