# This module sets common settings related to Nix such as enabling flakes and
# using overlays everywhere..
#
# NOTE: This lives under `shared/nixos-and-darwin`. The configuration in here
# should be compatible with both nixos and nix-darwin!!
{
  pkgs,
  lib,
  config,
  flakeInputs,
  flakeOutputs,
  ...
}:
lib.mkMerge [
  {
    # Enable de facto stable features.
    nix.settings.experimental-features = ["nix-command" "flakes"];

    nixpkgs.overlays = [
      # Use local overlays.
      flakeOutputs.overlays.additions
      flakeOutputs.overlays.modifications

      # Add unstable nixpkgs.
      (final: prev: {unstable = flakeInputs.nixpkgs-unstable.legacyPackages.${pkgs.system};})
    ];

    # I'm not *that* vegan.
    nixpkgs.config.allowUnfree = true;

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    nix.registry = lib.mapAttrs (_: value: {flake = value;}) flakeInputs;

    nix.nixPath =
      [
        # Use overlays from this repo for building system configuration as well as system-wide.
        # See: https://nixos.wiki/wiki/Overlays#Using_nixpkgs.overlays_from_configuration.nix_as_.3Cnixpkgs-overlays.3E_in_your_NIX_PATH
        "nixpkgs-overlays=${flakeInputs.self}/overlays/compat.nix"
      ]
      # This will additionally add out inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      ++ lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    # Add shell-utilities which are only relevant if Nix is enabled.
    environment.systemPackages = with pkgs; [
      # For running programs easily.
      nix-index # Also includes nix-locate
      flakeInputs.comma.packages.${system}.default

      # For editing secrets.
      flakeInputs.agenix.packages.${system}.default
    ];
  }
  (lib.mkIf pkgs.stdenv.isLinux {
    # There is not nix-darwin equivalent to this NixOS option.
    nix.enable = true;
  })
]
