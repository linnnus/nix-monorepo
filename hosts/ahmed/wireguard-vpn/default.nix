# This module sets up thi sserver as a VPN exit node. We define a virtual
# private network on 10.100.0.0/16 which all the devices are connected to.
# Since this host is guaranteed to have a static ip address, all trafic is
# routed through here.
{
  pkgs,
  config,
  metadata,
  ...
}: let
  wireguardInterface = "wgvpn"; # wg0 is used for torrenting.

  externalInterface = "enp0s31f6";
in {
  networking.wireguard.interfaces.${wireguardInterface} = {
    # This is "network" part of VPN. Also defines the IP of this host within that virtual network.
    ips = ["10.100.0.1/16"];

    # The port that WireGuard listens to. Must be accessible by the client.
    listenPort = metadata.hosts.ahmed.wireguard.port;

    # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
    postSetup = "${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/16 -o eth0 -j MASQUERADE";
    postShutdown = "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/16 -o eth0 -j MASQUERADE";

    privateKeyFile = config.age.secrets.wireguard-vpn-key.path;

    peers = [
      {
        # Muhammed
        publicKey = metadata.hosts.muhammed.wireguard.pubkey;
        allowedIPs = ["10.100.0.2/32"];
      }
      {
        # iPhone
        publicKey = "/BCjhCe68dSoORo9XQvGsUKOos/h1xu3LaAJoHvn/yw=";
        allowedIPs = ["10.100.0.3/32"];
      }
    ];
  };

  # Allow connections to the wireguard server. All clients need to connect to
  # this port.
  networking.firewall.allowedUDPPorts = [metadata.hosts.ahmed.wireguard.port];

  # Get the private keys.
  age.secrets.wireguard-vpn-key.file = ../../../secrets/wireguard-keys/ahmed.age;

  # Forward packets from wireguard onto the LAN while also doing address translation.
  networking.nat = {
    enable = true;
    inherit externalInterface;
    internalInterfaces = [wireguardInterface];
  };

  # Allow DNS from Wireguard.
  services.dnscache.clientIps = ["10.100"];
}
