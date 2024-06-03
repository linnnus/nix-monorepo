# This file contains the configuration for my Macbook Pro.
{flakeInputs, ...}: {
  imports = [
    ./home
  ];

  # Specify the location of this configuration file. Very meta.
  environment.darwinConfig = flakeInputs.self + "/hosts/muhammed/configuration.nix";

  # Avoid downloading the nixpkgs tarball every hour.
  # See: https://cohost.org/fullmoon/post/1728807-nix-s-tarball-ttl-op
  nix.settings.tarball-ttl = 604800;

  # Use the Nix daemon.
  services.nix-daemon.enable = true;

  # Set up main account with ZSH.
  users.users.linus = {
    description = "Personal user account";
    home = "/Users/linus";
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
    ];
  in ''
    %admin ALL=(ALL:ALL) NOPASSWD: ${builtins.concatStringsSep ", " commands}
  '';

  services.still-awake.enable = true;

  # Create a local Linux builder. This will allow us to build aarch64-linux
  # targets directly on this machine.
  nix.settings.trusted-users = ["linus"];
  nix.linux-builder = {
    enable = true;

    # Clearing the VM state upon startup should improve reliability at the cost
    # of some startup speed. Will have to re-evaluate if this trade off is
    # worth it at some point.
    ephemeral = true;

    config = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        # cntr is used to jump into the sandbox of packages that use breakpointHook.
        pkgs.cntr

        # Nix is used to debug and fetch other tools as needed.
        pkgs.nix
      ];

      # Allow root login. This would normally be horrible but it's a local VM so who cares.
      users.users.root.hashedPassword = "$y$j9T$TosKLKCZ.g9be.Wz5/qVJ.$YWvn4nAp8tn.xhHGBMOz748PHma6QGhN/WShilEbz8A";
      services.openssh.permitRootLogin = "yes";
    };
  };

  # System-specific version info.
  home-manager.users.linus.home.stateVersion = "22.05";
  system.stateVersion = 4;
}
