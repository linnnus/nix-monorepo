# This module configures the my torrenting setup. It uses qBittorrent over a VPN.
{
  pkgs,
  options,
  config,
  ...
}: let
  downloadPath = "/srv/media/";

  qbWebUiPort = 8082;
  qbListeningPort = 52916;

  wgInterface = "wg0";
  wgPort = 51820;

  qbDomain = "qbittorrent.ulovlighacker.download";
  jellyfinDomain = "ulovlighacker.download";
  useACME = true;
in {
  # Configure the actual qBittorrent service.
  services.qbittorrent = {
    enable = true;

    # We will use a reverse proxy in front of qBittorrent.
    openFirewall = false;
    port = qbWebUiPort;

    settings = {
      BitTorrent = {
        # Use the specified download path for finished torrents.
        "Session\\DefaultSavePath" = downloadPath;
        "Session\\TempPath" = "${config.services.qbittorrent.profile}/qBittorrent/temp";
        "Session\\TempPathEnabled" = true;

        # Instruct qBittorrent to only use VPN interface.
        "Session\\Interface" = wgInterface;
        "Session\\InterfaceName" = wgInterface;

        "Session\\Port" = qbListeningPort;
      };

      Preferences = {
        "Downloads\\SavePath" = downloadPath;
        "General\\Locale" = "da";

        # Used in conjunction with the --webui-port flag (via services.qbittorrent.port)
        # since we'll be using a reverse proxy.
        "WebUI\\UseUPnP" = false;
      };
    };
  };

  systemd.services.qbittorrent.unitConfig.After = ["wireguard-${wgInterface}.target"];

  # Create the directory to which media will be downloaded.
  # This is also used by Jellyfin to serve the files.
  systemd.tmpfiles.rules = let
    user = config.services.qbittorrent.user;
    group = config.services.qbittorrent.group;
  in [
    "d ${downloadPath} 0755 ${user} ${group}"
  ];

  # Create a connection to Mullvad's WireGuard server.
  networking.wireguard.interfaces = {
    ${wgInterface} = {
      # The port to use for communication. This should also be opened in the firewall.
      ips = ["10.70.101.133/32" "fc00:bbbb:bbbb:bb01::7:6584/128"];
      privateKeyFile = config.age.secrets.mullvad-wg-key.path;
      allowedIPsAsRoutes = false;
      listenPort = wgPort;

      # Create a differente networking namespace to isolate the qBittorent
      # process. I decided not to do this because connecting the WebUI to NGINX
      # becomes a bit tricky then. I will keep it around just in case I take up
      # this issue again sometime later.
      #
      # Remember, you would also need to set NetworkNamespacePath= on
      # qBittorrent [0]. The network namespace would when be located under
      # /run/netns/${wgNamespace}.
      #
      # [0]: https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#NetworkNamespacePath=
      #
      # interfaceNamespace = wgNamespace;
      # preSetup = ''
      #   echo "Setting up namespace: ${wgNamespace}"
      #   ${pkgs.iproute2}/bin/ip netns add ${wgNamespace}
      #   ${pkgs.iproute2}/bin/ip -n ${wgNamespace} link set lo up
      # '';
      # postShutdown = ''
      #   echo "Tearing down namespace: ${wgNamespace}"
      #   ${pkgs.iproute2}/bin/ip netns del "${wgNamespace}"
      # '';

      # Since this is a client configuration, we only need a single peer: the Mullvad server.
      peers = [
        {
          # The public key of the server.
          publicKey = "/iivwlyqWqxQ0BVWmJRhcXIFdJeo0WbHQ/hZwuXaN3g=";

          # The location of the server.
          endpoint = "193.32.127.66:${toString wgPort}";

          # Which destination IPs should be directed to this ip/pubkey pair. In
          # this case, we send all packets to our only peer.
          #
          # NOTE: It is important the we either use a network namespace or set
          # `allowedIPsAsRoutes = false` as otherwise we run into the loop
          # routing problem.
          #
          # See: https://wiki.archlinux.org/title/WireGuard#Loop_routing
          # See: https://cohost.org/linuwus/post/5040530-an-unexpected-soluti
          allowedIPs = ["0.0.0.0/0" "::/0"];

          # Send keepalives messages. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Here we load the secret file containing this clients private key. It is
  # defined in the configuration file from Mullvad's website.
  age.secrets.mullvad-wg-key.file = ../../../secrets/mullvad-wg.key.age;

  # TODO: Use Peer as DNS server: https://arc.net/l/quote/axlprdca

  services.jellyfin = {
    enable = true;
    # We use a reverse proxy.
    openFirewall = false;
  };

  # Use NGINX as a reverse proxy for the various services that present web UIs.
  services.nginx = {
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

  services.cloudflare-dyndns.domains = [
    qbDomain
    jellyfinDomain
  ];

  networking.firewall = {
    # Clients and peers use the same port. I'm actually not sure we need to
    # accept incomming connections as clients participating in the wireguard
    # protocol.
    allowedUDPPorts = [wgPort];

    # This is a weird fix. Apparently the rpfilter set up as part of
    # nixos-rpfilter in the 'mangle' table will block WireGuard traffic.
    # Setting this to "loose" somehow fixes that.
    #
    # See: https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577/2?u=linnnus
    # See: https://github.com/NixOS/nixpkgs/issues/51258#issuecomment-448005659
    checkReversePath = "loose";
  };
}
