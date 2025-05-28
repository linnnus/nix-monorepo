# This file contains the configuration for my Macbook Pro.
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../shared/nixos-and-darwin/common-shell-settings
    ../../shared/darwin/common-nix-settings
    ../../shared/nixos-and-darwin/common-hm-settings

    ./remote-builders
    ./update-git-repos
    ./wireguard
  ];

  # Avoid downloading the nixpkgs tarball every hour.
  # See: https://cohost.org/fullmoon/post/1728807-nix-s-tarball-ttl-op
  nix.settings.tarball-ttl = 604800;

  # Set up main account.
  users.users.linus = {
    description = "Personal user account";
    home = "/Users/linus";
  };

  home-manager.users.linus = {
    imports = [
      ../../shared/home-manager/development-full
      ../../shared/home-manager/qbittorrent
      ../../shared/home-manager/iterm2
      ./extra-utils.nix
      ./syncthing.nix
    ];
  };

  # Should match containing folder.
  networking.hostName = "muhammed";

  # Let's use fingerprint to authenticate sudo. Very useful as an indicator of
  # when darwin-rebuild is finished...
  security.pam.services.sudo_local.touchIdAuth = true;

  # Don't request password for running pmset.
  environment.etc."sudoers.d/10-unauthenticated-commands".text = let
    commands = [
      "/usr/bin/pmset"
      (lib.getExe pkgs.disable-sleep)
    ];
  in ''
    %admin ALL=(ALL:ALL) NOPASSWD: ${builtins.concatStringsSep ", " commands}
  '';

  services.still-awake.enable = true;

  # Enable nightly GC of Nix store.
  nix.gc = {
    automatic = true;
    interval = {Hour = 3;};
  };

  # System-specific version info.
  home-manager.users.linus.home.stateVersion = "22.05";
  system.stateVersion = 4;
}
