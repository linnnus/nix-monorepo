{metadata, config, ...}: {
  networking.wg-quick.interfaces.wg0 = {
    # Use the address assigned for us in `hosts/ahmed/wireguard-vpn/default.nix`.
    address = ["10.100.0.2"];

    # Use DNS server set up in `hosts/ahmed/local-dns/default.nix`.
    dns = ["10.100.0.1" "1.1.1.1"];

    privateKeyFile = config.age.secrets.wireguard-key.path;

    peers = [(let
      peerInfo = metadata.hosts.ahmed.wireguard;
    in {
      publicKey = peerInfo.pubkey;
      allowedIPs = ["0.0.0.0/0" "::/0"];
      endpoint = "${peerInfo.ipv4Address}:${toString peerInfo.port}";
      persistentKeepalive = 5; # We are a roaming client, they are static.
    })];

    # table = "off";
  };

  age.secrets.wireguard-key.file = ../../../secrets/wireguard-keys/muhammed.age;
}
