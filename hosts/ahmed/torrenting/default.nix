# This module configures the my torrenting setup. It uses qBittorrent over a VPN.
{
  pkgs,
  options,
  config,
  ...
}: {
  imports = [
    ./wireguard.nix
    ./reverse-proxy.nix
    ./save-path.nix
  ];

  services.qbittorrent = {
    enable = true;

    # We need unstable until at least 5.0.1 becomes part of stable nixpkgs.
    # See: https://sharpsec.run/rce-vulnerability-in-qbittorrent/
    package = pkgs.unstable.qbittorrent-nox;

    settings = {
      Preferences = {
        # Configure credentials. This should be safe to keep here, since the password is hashed.
        "WebUI\\Username" = "linus";
        "WebUI\\Password_PBKDF2" = "@ByteArray(KCBHD0C70+/50xW/zkIUiw==:WY6phmLjJza//fD6w6fXwqzLCYIQjFMRQ3hlqYVIRcKVNHh1fYjMHlI1aBPciJtDdBABq3/D2hOuhQpAt3oUXQ==)";
      };
    };
  };

  services.jellyfin.enable = true;
}
