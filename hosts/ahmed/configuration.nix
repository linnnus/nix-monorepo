# This file conatins the host-specific configuration for a shitty webserver in
# my closet.

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./ssh.nix
    ];

  # Create the main user
  users.users.linus = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$kNJ5L50Si0sAhdrHyO19I1$YcwXZ46dI.ApLMgZSj7qImq9FrSL0CEUeoJUS8P1103";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
  home-manager.users.linus.home.stateVersion = "22.05";
  my.use-cases.development.enable = true;
  my.use-cases.sysadmin.enable = true;
  # Following are recommended when changing the default shell.
  # https://nixos.wiki/wiki/Command_Shell#Changing_default_shelltrue;
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.device = "/dev/mmcblk0p3"; # FIXME: Do we need to specify GRUB device?
  boot.loader.efi.canTouchEfiVariables = false;

  # The hostname should match the containing folder.
  networking.hostName = "ahmed";

  # This host is located in Denmark.
  time.timeZone = "Europe/Copenhagen";

  console = {
    font = "sun12x22"; # This font is pretty readable on the cracked display.
    keyMap = "dk";     # This host has a Danish keyboard layout.
  };

  # Disable sleep on lid close.
  # FIXME: Screen does not appear to turn off when closed.
  services.logind.extraConfig =
    let
      lidSwitchAction = "ignore";
    in
    ''
      HandleLidSwitch=${lidSwitchAction}
      HandleLidSwitchDocked=${lidSwitchAction}
      HandleLidSwitchExternalPower=${lidSwitchAction}
    '';

  # Configure WiFi at computer's location.
  # FIXME: Don't store in plain text.
  networking.wireless.enable = true;
  networking.wireless.networks."Rumpenettet_Guest".psk = "Rumpenerglad"; # NOCOMMIT

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
