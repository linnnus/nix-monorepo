# This module configures a reverse proxy for the various services that are
# exposed to the internet.
{config, ...}: let
  # The internal port where qBittorrents web UI will be served.
  qbWebUiPort = 8082;
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
    virtualHosts."qbittorrent.${config.linus.local-dns.domain}" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString qbWebUiPort}";
        recommendedProxySettings = true;
      };
    };

    virtualHosts."jellyfin.${config.linus.local-dns.domain}" = {
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
        proxyWebsockets = true;
      };
    };
  };

  linus.local-dns.subdomains = [
    "qbittorrent"
    "jellyfin"
  ];
}
