{
  metadata,
  config,
  ...
}: {
  networking.wg-quick.interfaces."rumpenettet" = {
    # Use the address assigned for us in `hosts/ahmed/wireguard-vpn/default.nix`.
    address = ["10.100.0.2"];

    # Use DNS server set up in `hosts/ahmed/local-dns/default.nix`.
    dns = ["10.100.0.1" "1.1.1.1"];

    privateKeyFile = config.age.secrets.wireguard-key.path;

    # We only want to use this when we are away from home. However when we *do*
    # use it, it should be the default route.
    autostart = false;
    table = "auto";

    peers = [
      (let
        peerInfo = metadata.hosts.ahmed.wireguard;
      in {
        publicKey = peerInfo.pubkey;
        allowedIPs = ["0.0.0.0/0" "::/0"];
        endpoint = "${peerInfo.ipv4Address}:${toString peerInfo.port}";
        persistentKeepalive = 5; # We are a roaming client, they are static.
      })
    ];
  };

  age.secrets.wireguard-key.file = ../../../secrets/wireguard-keys/muhammed.age;
}
