# This file contains the configuration for my Macbook Pro.

{ pkgs, inputs, lib, ... }:

{
  # Specify the location of this configuration file. Very meta.
  environment.darwinConfig = inputs.self + "/hosts/muhammed/configuration.nix";

  # Use the Nix daemon.
  services.nix-daemon.enable = true;

  # Set up main account.
  users.users.linus = {
    description = "Personal user account";
    home = "/Users/linus";
    shell = pkgs.zsh;
  };
  my.use-cases.development.enable = true;
  my.use-cases.sysadmin.enable = true;
  # Following are recommended when changing the default shell.
  # https://nixos.wiki/wiki/Command_Shell#Changing_default_shelltrue;
  programs.zsh.enable = true; # TODO: move to common module
  environment.shells = [ pkgs.zsh ];

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
