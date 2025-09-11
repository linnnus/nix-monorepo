# Adds TagStudio.
# FIXME: Configuration is still stored mutably.
{pkgs, ...}: {
  # The official flake relies on nixos-unstable and does not seem consistently maintained.
  home.packages = [pkgs.tagstudio-bin];
}
