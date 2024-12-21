# This module sets common settings related to home-manager (HM). All hosts that
# I directly interact with should include this module.
#
# NOTE: Even though this lives under `shared/nixos` the configuration in here
# should also be compatible with nix-darwin!!
{
  flakeInputs,
  flakeOutputs,
  metadata,
  ...
}: {
  # FIXME: Ideally this module would import flakeInputs.home-manager but that causes an infinite recursion for some reason.

  # Use the flake input pkgs so Home Manager configuration can share overlays
  # etc. with the rest of the configuration.
  home-manager.useGlobalPkgs = true;

  # Pass special arguments from flake.nix further down the chain. I really hate
  # this split module system.
  home-manager.extraSpecialArgs = {inherit flakeInputs flakeOutputs metadata;};

  # All interactive systems (i.e. the ones that would use HM) have a 'linus' user.
  home-manager.users.linus = {
    imports = builtins.attrValues flakeOutputs.homeModules;
    xdg.enable = true;
  };
}
