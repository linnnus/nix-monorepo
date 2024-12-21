# This file contains the configuration for my Macbook Pro.
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../shared/nixos/common-shell-settings
    ../../shared/nixos/common-nix-settings
    ../../shared/nixos/common-hm-settings

    ./remote-builders
  ];

  # Avoid downloading the nixpkgs tarball every hour.
  # See: https://cohost.org/fullmoon/post/1728807-nix-s-tarball-ttl-op
  nix.settings.tarball-ttl = 604800;

  # Use the Nix daemon.
  services.nix-daemon.enable = true;

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
      ({pkgs, ...}: {
        home.packages = with pkgs; [
          imagemagick
          ffmpeg_6-full
        ];
      })
    ];
  };

  # Should match containing folder.
  networking.hostName = "muhammed";

  # Let's use fingerprint to authenticate sudo. Very useful as an indicator of
  # when darwin-rebuild is finished...
  security.pam.enableSudoTouchIdAuth = true;

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
