# This file conatins the host-specific configuration for a shitty webserver in
# my closet.
{
  config,
  pkgs,
  metadata,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./ssh.nix
  ];

  # Create the main user.
  users.users.linus = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$UmZES4WC8FWrjBvdazq2e/$rzneAKZeySwSVKiSZJfXC.fciiQdGqxB5uyRaPQ6OF.";
    extraGroups = ["wheel"];
  };
  users.mutableUsers = false;

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
    package = pkgs.papermc;
    openFirewall = true;
    # Try shutting down every 10 minutes.
    frequency-check-players = "*-*-* *:00/10:00";
  };
  services.cloudflare-dyndns.domains = ["minecraft.linus.onl"];

  # Set up dukse server. Det er satme hårdt at være overduksepåmindelsesansvarlig.
  services.duksebot.enable = true;

  # Virtual hosts.
  services.nginx.enable = true;
  modules."linus.onl" = {
    enable = true;
    useACME = true;
  };
  modules."notifications.linus.onl" = {
    enable = true;
    useACME = true;
  };
  modules."git.linus.onl" = {
    enable = true;
    useACME = true;
  };

  # Configure ACME for various HTTPS services.
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
  systemd.services.cloudflare-dyndns.after = [ "network-online.target" ];

  # Listen for HTTP connections.
  networking.firewall.allowedTCPPorts = [80 443];

  # We are running behind CF proxy.
  modules.cloudflare-proxy = {
    enable = true;
    firewall.IPv4Whitelist = [metadata.hosts.muhammed.ipAddress];
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
