# Manages remote Nix builders. These are useful for building faster and for
# other architectures.
{...}: {
  imports = [
    ./local-linux-builder.nix
    ./ahmed-builder.nix
  ];

  # Enable using remote builders.
  nix.distributedBuilds = true;

  # Optional, useful when the builder has a faster internet connection than
  # yours. This may be the case since this host is a laptop and one of the
  # remote builders isn't.
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
