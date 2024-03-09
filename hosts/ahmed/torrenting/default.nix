# This module configures the my torrenting setup. It uses qBittorrent over a VPN.
{pkgs, options, config, ...}: let
  downloadPath = "/srv/media/";

  interface = "tun0";
in {
  # Configure the actual qBittorrent service.
  services.qbittorrent = {
    enable = true;

    openFirewall = true; # TEMP: reverse proxy will cover this instead

    settings = {
      BitTorrent = {
        # Use the specified download path for finished torrents.
        "Session\\DefaultSavePath" = downloadPath;
        "Session\\TempPath" = "${config.services.qbittorrent.profile}/qBittorrent/temp";
        "Session\\TempPathEnabled" = true;
      };

      # Instruct qBittorrent to only use VPN interface.
    };
  };

  # Create the directory to which media will be downloaded.
  # This is also used by Jellyfin to serve the files.
  systemd.tmpfiles.rules = let
    user = options.services.qbittorrent.user.default;
    group = options.services.qbittorrent.group.default;
  in [
    "d ${downloadPath} 0755 ${user} ${group}"
  ];

  # Create a connection to Mullvad's WireGuard server.

  # Use NGINX as a reverse proxy for qBittorrent's WebUI.
}
