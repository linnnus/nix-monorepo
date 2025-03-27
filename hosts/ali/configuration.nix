{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../shared/nixos/common-nix-settings
    ../../shared/nixos/common-shell-settings
    ../../shared/nixos-and-darwin/common-hm-settings
    ../../shared/nixos/danish

    ./wireless-networking
    ./desktop-environment
    ./remote-builders
  ];

  # Should match containing folder.
  networking.hostName = "ali";

  boot.loader.grub = {
    # Use the GRUB 2 boot loader.
    enable = true;

    # Install grub on the main HDD.
    device = "/dev/sda";
  };

  # Create the main user.
  users.users.linus = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$UmZES4WC8FWrjBvdazq2e/$rzneAKZeySwSVKiSZJfXC.fciiQdGqxB5uyRaPQ6OF.";
    extraGroups = ["wheel"];
  };
  users.mutableUsers = false;

  home-manager.users.linus = {
    imports = [
      ../../shared/home-manager/development-minimal
      ../../shared/home-manager/nix
      ../../shared/home-manager/C
    ];
    home.stateVersion = "24.11";
  };

  system.stateVersion = "24.11";
}
