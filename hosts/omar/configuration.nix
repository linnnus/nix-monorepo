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
    ../../shared/nixos/zfs-impermenance
    ../../shared/nixos/persist-ssh-host-keys
    ../../shared/nixos/danish

    ./wireless-networking
    ./desktop-environment
  ];

  boot.loader.grub = {
    # Use the GRUB 2 boot loader.
    enable = true;

    # Install grub on the main HDD.
    device = "/dev/sda";

    # ZFS on root requires GRUB to be able to read the pool.
    # The pool was created with `-o compatibility=grub2`.
    zfsSupport = true;
  };

  # The host id is required by ZFS.
  # It is used to (among other things) avoid multiple hosts modifying the same dataset unsafely.
  # This was randomly generated.
  networking.hostId = "b6e8e80a";

  # Should match containing folder.
  networking.hostName = "omar";

  # Create the main user.
  users.users.linus = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$UmZES4WC8FWrjBvdazq2e/$rzneAKZeySwSVKiSZJfXC.fciiQdGqxB5uyRaPQ6OF.";
    extraGroups = ["wheel"];
  };
  users.mutableUsers = false;

  home-manager.users.linus = {
    imports = [
      # I am planning on using this host when traveling.
      ../../shared/home-manager/development-full
    ];
    home.stateVersion = "24.11";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "24.11";
}
