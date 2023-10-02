# This file conatins the host-specific configuration for a shitty webserver in
# my closet.
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./ssh.nix
    ./linus.onl.nix
    ./notifications.linus.onl.nix
    ./graphics.nix
  ];

  # Create the main user.
  users.users.linus = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$kNJ5L50Si0sAhdrHyO19I1$YcwXZ46dI.ApLMgZSj7qImq9FrSL0CEUeoJUS8P1103";
    extraGroups = ["wheel"];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.device = "/dev/mmcblk0p3"; # FIXME: Do we need to specify GRUB device?
  boot.loader.efi.canTouchEfiVariables = false;

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

  # Configure ACME for various HTTPS services.
  security.acme = {
    acceptTerms = true;
    defaults.email = "linusvejlo+${config.networking.hostName}-acme@gmail.com";
  };

  # Configure DDNS. The website for each module is responsible for extending `services.cloudflare-dyndns.domains` with its domain.
  age.secrets.cloudflare-dyndns-api-token.file = ../../secrets/cloudflare-ddns-token.env.age;
  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare-dyndns-api-token.path;
    proxied = true;
  };

  # Listen for HTTP connections.
  networking.firewall.allowedTCPPorts = [80 443];

  # We are running behind CF proxy.
  modules.cloudflare-proxy.enable = true;

  # Use as main driver temporarily.
  # modules.graphics.enable = true;

  disable-screen = {
    enable = true;
    # The path to the device.
    device-path = "/sys/class/backlight/intel_backlight";

    # The systemd device unit which corresponds to `device-path`.
    device-unit = "sys-devices-pci0000:00-0000:00:02.0-drm-card0-card0\\x2deDP\\x2d1-intel_backlight.device";
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
