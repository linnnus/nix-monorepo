{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../shared/nixos-and-darwin/common-nix-settings
    ../../shared/nixos-and-darwin/common-shell-settings
    ../../shared/nixos-and-darwin/common-hm-settings
    ../../shared/nixos/zfs-impermenance

    ./wireless-networking
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
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "24.11";
}
