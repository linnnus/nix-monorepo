# This module configures the my torrenting setup. It uses qBittorrent over a VPN.
{
  pkgs,
  options,
  config,
  ...
}: let
  downloadPath = "/srv/media/";
in {
  imports = [
    ./wireguard.nix
    ./reverse-proxy.nix
  ];

  # Configure the actual qBittorrent service.
  services.qbittorrent = {
    enable = true;

    settings = {
      BitTorrent = {
        # Use the specified download path for finished torrents.
        "Session\\DefaultSavePath" = downloadPath;
        "Session\\TempPath" = "${config.services.qbittorrent.profile}/qBittorrent/temp";
        "Session\\TempPathEnabled" = true;
      };

      Preferences = {
        # Again??
        "Downloads\\SavePath" = downloadPath;
      };
    };
  };

  # WARNING: Jellyfin has been manually configured to serve from the correct download path.
  services.jellyfin.enable = true;

  # Create the directory to which media will be downloaded. This will be used
  # by qBittorent to hold files and Jellyfin will serve from it.
  systemd.tmpfiles.rules = let
    user = config.services.qbittorrent.user;
    group = config.services.qbittorrent.group;
  in [
    "d ${downloadPath} 0755 ${user} ${group}"
  ];
}
