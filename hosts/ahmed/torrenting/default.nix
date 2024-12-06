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
        "WebUI\\Password_PBKDF2" = "@ByteArray(wOEz+v4PMOZTIUxD+NI0sQ==:uEp16/vHvNgv71RcHHBuxm7WgjqgVZpuEWEG1KnCxrCxGX1n3y2cqQyGYDLBlpyGv8rjk3G0g+d5xuxW1izV2g==)";
      };
    };
  };

  services.jellyfin.enable = true;
}
