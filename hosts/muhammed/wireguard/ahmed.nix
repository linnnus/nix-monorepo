{
  metadata,
  config,
  ...
}: {
  networking.wg-quick.interfaces."rumpevpn" = {
    # Use the address assigned for us in `hosts/ahmed/wireguard-vpn/default.nix`.
    address = [metadata.hosts.muhammed.networks.rumpevpn.v4];

    # Use DNS server set up in `hosts/ahmed/local-dns/default.nix`.
    dns = [metadata.hosts.ahmed.networks.rumpevpn.v4 "1.1.1.1"];

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
        endpoint = "${peerInfo.v4}:${toString peerInfo.port}";
        persistentKeepalive = 5; # We are a roaming client, they are static.
      })
    ];
  };

  age.secrets.wireguard-key.file = ../../../secrets/wireguard-keys/muhammed.age;
}
