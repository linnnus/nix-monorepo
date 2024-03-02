# Adds qbittorrent.
# FIXME: Configuration is still stored mutably.
{pkgs, ...}: {
  home.packages = [pkgs.qbittorrent];
}
