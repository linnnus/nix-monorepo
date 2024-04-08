# This module configures a WireGuard for qBittorrent to use.

{
  config,
  ...
}: let
  wgInterface = "wg0";
  wgPort = 51820;
in {
  # TODO: Use Peer as DNS server: https://arc.net/l/quote/axlprdca

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

  # Configure qBittorrent to only torrent through the wireguard interface.
  services.qbittorrent.settings = {
    Bittorrent = {
      "Session\\Interface" = wgInterface;
      "Session\\InterfaceName" = wgInterface;
    };
  };

  # We also instruct qBittorrent to wait for the wireguard interface to come
  # online. This lets us avoid an awkward interim where qBittorrent is live
  # but can't torrent anything.
  #
  # FIXME: Maybe not strictly necessary.
  systemd.services.qbittorrent.unitConfig.After = ["wireguard-${wgInterface}.target"];
}
