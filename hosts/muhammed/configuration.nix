# This file contains the configuration for my Macbook Pro.

{ pkgs, flakeInputs, lib, ... }:

{
  # Specify the location of this configuration file. Very meta.
  environment.darwinConfig = flakeInputs.self + "/hosts/muhammed/configuration.nix";

  # Use the Nix daemon.
  services.nix-daemon.enable = true;

  # Set up main account with ZSH.
  users.users.linus = {
    description = "Personal user account";
    home = "/Users/linus";
  };

  # Should match containing folder.
  networking.hostName = "muhammed";

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

  # System-specific version info.
  home-manager.users.linus.home.stateVersion = "22.05";
  system.stateVersion = 4;
}
