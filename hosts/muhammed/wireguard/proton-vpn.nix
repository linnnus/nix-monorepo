# This module configures a WireGuard for qBittorrent to use.
{config, ...}: {
  # Create a connection to Proton's WireGuard server.
  networking.wg-quick.interfaces."torrent" = {
    address = ["10.3.0.2/32"];
    privateKeyFile = config.age.secrets.proton-wg-key.path;

    # We want this interface to always be active in the background.
    autostart = true;
    table = "auto";

    # Since this is a client configuration, we only need a single peer: the Proton server.
    peers = [
      {
        # The public key of the server.
        publicKey = "9WowgFUh2itRfPh2SoaJsJHvxzXBZuD+xqdmBAf2CB4=";

        # The location of the server.
        endpoint = "149.50.217.161:51820";

        # Which destination IPs should be directed to this ip/pubkey pair. In
        # this case, we send all packets to our only peer.
        #
        # NOTE: It is important the we either use a network namespace or set
        # `table = "off"` as otherwise we run into the loop
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

  # Here we load the secret file containing this clients private key. It is
  # defined in the configuration file from Proton's website.
  age.secrets.proton-wg-key.file = ../../../secrets/mullvad-wg.key.age;
}
