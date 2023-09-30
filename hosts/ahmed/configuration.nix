# This file conatins the host-specific configuration for a shitty webserver in
# my closet.

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./ssh.nix
      ./disable-screen.nix
      ./cloudflare-ddns.nix
    ];

  # Create the main user.
  users.users.linus = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$kNJ5L50Si0sAhdrHyO19I1$YcwXZ46dI.ApLMgZSj7qImq9FrSL0CEUeoJUS8P1103";
    extraGroups = [ "wheel" ];
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
    keyMap = "dk";     # This host has a Danish keyboard layout.
  };

  # Set up Minecraft server.
  my.services.on-demand-minecraft = {
    enable = true;
    eula = true;
    package = pkgs.papermc;
    openFirewall = true;
  };

  my.services.duksebot.enable = true;

  # Host <https://linus.onl>.
  my.modules."linus.onl" = {
    enable = true;
    useACME = true;
    openFirewall = true;
  };

  # Configure ACME for various HTTPS services.
  security.acme = {
    acceptTerms = true;
    defaults.email = "linusvejlo+${config.networking.hostName}-acme@gmail.com";
  };

  # We are running behind CF proxy.
  my.modules.cloudflare-proxy.enable = true;

  # Use as main driver temporarily.
  # my.modules.graphics.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  home-manager.users.linus.home.stateVersion = "22.05";
}
