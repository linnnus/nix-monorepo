# Returns a list of overlays such that this file can be used for the value of
# nixpkgs-overlays in NIX_PATH.
#
# See: shared/nixos/common-nix-options/
# See: https://nixos.org/manual/nixpkgs/stable/#sec-overlays-lookup
[
  (import ./additions.nix)
  (import ./modifications.nix)
]
