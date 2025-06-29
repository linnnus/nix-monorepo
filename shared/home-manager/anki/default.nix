# Adds anki.
# FIXME: Configuration is still stored mutably.
{pkgs, ...}: {
  # Source build seems to be broken on aarch64-darwin as of nixpkgs@c7ab75210cb8.
  home.packages = [pkgs.anki-bin];
}
