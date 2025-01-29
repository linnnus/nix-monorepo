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
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.cleanOnBoot = true;

  # The hostname should match the containing folder.
  networking.hostName = "ahmed";

  # This host is located in Denmark.
  time.timeZone = "Europe/Copenhagen";

  console = {
    font = "sun12x22"; # This font is pretty readable on the cracked display.
    keyMap = "dk"; # This host has a Danish keyboard layout.
  };

  # Set up Minecraft server.
  services.on-demand-minecraft = {
    enable = true;
    eula = true;
    package = pkgs.unstable.papermc;
    openFirewall = true;
    # Try shutting down every 10 minutes.
    frequency-check-players = "*-*-* *:00/10:00";

    # Seed requested by Tobias.
    server-properties."level-seed" = "1727502807";
  };
  services.cloudflare-dyndns.domains = ["minecraft.linus.onl"];

  # Virtual hosts.
  # Each module for a HTTP service will register a virtual host.
  services.nginx.enable = true;

  # Configure ACME. This is used by various HTTP services through the NGINX virtual hosts.
  security.acme = {
    acceptTerms = true;
    defaults.email = "linusvejlo+${config.networking.hostName}-acme@gmail.com";
  };

  # Configure DDNS. The website for each module is responsible for extending
  # `services.cloudflare-dyndns.domains` with its domain.
  age.secrets.cloudflare-dyndns-api-token.file = ../../secrets/cloudflare-ddns-token.env.age;
  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare-dyndns-api-token.path;
    proxied = true;
  };
  # We also have to overwrite the dependencies of the DYNDNS client service to
  # make sure we are *actually* online.
  #
  # See: https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget
  systemd.services.cloudflare-dyndns.after = ["network-online.target"];

  # Listen for HTTP connections.
  networking.firewall.allowedTCPPorts = [80 443];

  # Automatic upgrades
  system.autoUpgrade = {
    enable = true;
    flake = "github:linnnus/nix-monorepo";
    flags = [
      # Update nixpkgs inputs to recieve security patches and such.
      # Since the updated lockfile isn't commited, we still have to bump manually also.
      "--update-input"
      "nixpkgs"
      "--update-input"
      "nixpkgs-unstable"

      # Print build logs.
      "-L"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  home-manager.users.linus.home.stateVersion = "22.05";
}
