# This module configures a reverse proxy for the various services that are
# exposed to the internet.

{
  pkgs,
  config,
  lib,
  ...
}: let
  baseDomain = "ulovlighacker.download";
  wwwDomain = "www.${baseDomain}";
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

  services.jellyfin.openFirewall = false;

  # Use NGINX as a reverse proxy.
  services.nginx = {
    virtualHosts."${baseDomain}" = {
      enableACME = useACME;
      forceSSL = useACME;

      serverAliases = [wwwDomain];

      locations."/" = {
        index = "index.html";
        root = pkgs.runCommand "${baseDomain}-portal" { inherit qbDomain jellyfinDomain; } ''
          mkdir $out

          ${pkgs.xorg.lndir}/bin/lndir ${./portal} $out

          rm $out/index.html
          substituteAll ${./portal/index.html} $out/index.html
        '';
      };
    };

    virtualHosts.${qbDomain} = {
      enableACME = useACME;
      forceSSL = useACME;

      locations."/" = {
        proxyPass = "http://localhost:${toString qbWebUiPort}";
        recommendedProxySettings = true;
      };
    };

    virtualHosts.${jellyfinDomain} = {
      enableACME = useACME;
      forceSSL = useACME;

      locations."/" = {
        # This is the "static port" of the HTTP web interface.
        #
        # See: https://jellyfin.org/docs/general/networking/#port-bindings
        proxyPass = "http://localhost:8096";
        recommendedProxySettings = true;
      };
    };
  };

  # Register the domains with the DDNS client.
  services.cloudflare-dyndns.domains = [
    baseDomain
    wwwDomain
    qbDomain
    jellyfinDomain
  ];
}
