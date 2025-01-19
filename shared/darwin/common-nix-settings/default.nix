# This module sets common settings related to Nix such as enabling flakes and
# using overlays everywhere.
#
# Most of the heavy lifting is done in `shared/nixos-and-darwin/common-nix-settings`.
# This module is limited to Darwin-specific settings.
{
  imports = [
    ../../nixos-and-darwin/common-nix-settings
    ./sandbox.nix
  ];
}
