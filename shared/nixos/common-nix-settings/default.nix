# This module sets common settings related to Nix. Most of the logic is shared
# between NixOS and Darwin, and is found in `shared/nixos-and-darwin/common-nix-options/`.
{
  imports = [
    ../../nixos-and-darwin/common-nix-settings
  ];

  # There is not nix-darwin equivalent to this NixOS option.
  nix.enable = true;
}
