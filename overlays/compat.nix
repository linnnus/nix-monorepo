# Returns a list of overlays such that this file can be used for the value of
# nixpkgs-overlays in NIX_PATH.
#
# See: hosts/common.nix
# See: https://nixos.org/manual/nixpkgs/stable/#sec-overlays-lookup
let
  overlays = import ./default.nix;
in [
  overlays.additions
  overlays.modifications
]
