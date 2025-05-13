# This file conatins the host-specific configuration for a shitty webserver in
# my closet.
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ../../shared/nixos/cloudflare-proxy
    ../../shared/nixos/common-nix-settings
    ../../shared/nixos/common-shell-settings
    ../../shared/nixos-and-darwin/common-hm-settings

    ./git.linus.onl
    ./hellohtml.linus.onl
    ./linus.onl
    ./nofitications.linus.onl
    ./ssh
    ./torrenting
    ./remote-builder
    ./dyndns
    ./minecraft
    ./nginx
    ./local-dns
    ./vaultwarden
    ./wireguard-vpn
    ./syncthing
  ];

  # Create the main user.
  users.users.linus = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$UmZES4WC8FWrjBvdazq2e/$rzneAKZeySwSVKiSZJfXC.fciiQdGqxB5uyRaPQ6OF.";
    extraGroups = ["wheel"];
  };
  users.mutableUsers = false;

  home-manager.users.linus = {
    imports = [
      # Despite this being a "just a server" it is also the only x86_64-linux
      # host I have access to, so in practice I end up using it for development
      # sometimes.
      ../../shared/home-manager/development-minimal
      ../../shared/home-manager/nix
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # /boot keeps filling up
  boot.loader.systemd-boot.configurationLimit = 50;

  boot.tmp.cleanOnBoot = true;

  # The hostname should match the containing folder.
  networking.hostName = "ahmed";

  # This host is located in Denmark.
  time.timeZone = "Europe/Copenhagen";

  console = {
    font = "sun12x22"; # This font is pretty readable on the cracked display.
    keyMap = "dk"; # This host has a Danish keyboard layout.
  };

  # Automatic upgrades
  system.autoUpgrade = {
    enable = true;
    flake = "github:linnnus/nix-monorepo";
    flags = [
      # Update nixpkgs inputs to recieve security patches and such.
      # Since the updated lockfile isn't commited, we still have to bump manually also.
      # We don't bump nixpkgs-unstable as it is mainly used for packages for which I need a specific version (e.g. PaperMC).
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"

      # Print build logs.
      "-L"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  # Automatic garbage collection. The default value of running every night is
  # probably a bit overkill, but this system has very little storage.
  nix.gc.automatic = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  home-manager.users.linus.home.stateVersion = "22.05";
}
