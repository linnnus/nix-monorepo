# This module configures wireless networking using NetworkManager.
{
  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  users.users."linus".extraGroups = ["networkmanager"];
}
