# This file contains the configuration for my Macbook Pro.

{ pkgs, inputs, lib, ... }:

{
  # Specify the location of this configuration file. Very meta.
  # environment.darwinConfig = inputs.self + "/hosts/muhammed/configuration.nix";

  # Use the Nix daemon.
  services.nix-daemon.enable = true;

  # Set up main account.
  users.users.linus = {
    description = "Personal user account";
    home = "/Users/linus";
  };

  # Don't request password for running pmset.
  environment.etc."sudoers.d/10-unauthenticated-commands".text =
    let
      commands = [
        "/usr/bin/pmset"
      ];
    in
    ''
      %admin ALL=(ALL:ALL) NOPASSWD: ${builtins.concatStringsSep ", " commands}
    '';

  # Backwards compatability. Check `darwin-rebuild changelog` before bumping.
  system.stateVersion = 4;
}
