# This module configures wireless networking using NetworkManager.
{
  # Enable wireless networking via NetworkManager.
  networking = {
    networkmanager.enable = true;
    wireless.enable = false;
  };

  users.users."linus".extraGroups = ["networkmanager"];
}
