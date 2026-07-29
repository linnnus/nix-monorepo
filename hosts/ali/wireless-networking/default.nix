# This module configures wireless networking using NetworkManager.
{
  # Enable wireless networking via NetworkManager.
  networking = {
    networkmanager.enable = true;
  };

  users.users."linus".extraGroups = ["networkmanager"];
}
