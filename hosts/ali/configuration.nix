{flakeInputs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../shared/nixos/common-nix-settings
    ../../shared/nixos/common-shell-settings
    ../../shared/nixos-and-darwin/common-hm-settings
    ../../shared/nixos/danish

    ./remote-builders
    ./wireless-networking
    ./wireguard
  ];

  # The desktop environment is a bit heavy for this machine so it is placed in
  # a specialisation that can be selected at boot time.
  specialisation = {
    desktop-environment.configuration = {
      imports = [
        ./desktop-environment
      ];
    };
  };

  # Configure keymap in X11 *and* the console. This is should be active no
  # matter the specialisation.
  services.xserver.xkb.layout = "dk";
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;

  # Should match containing folder.
  networking.hostName = "ali";

  time.timeZone = "Europe/Copenhagen";

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
      ./extra-utils.nix
    ];
    home.stateVersion = "24.11";
  };

  age.identityPaths = ["/etc/ssh/host_ed25519_key"];

  system.stateVersion = "24.11";
}
