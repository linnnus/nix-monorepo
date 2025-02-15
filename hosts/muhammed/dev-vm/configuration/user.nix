{
  # Register the user which we will be logging into from the host.
  users.users.linus = {
    isNormalUser = true;
    password = "diller"; # Don't care. No security implications.
    extraGroups = ["wheel"];
  };

  home-manager.users.linus = {
    imports = [
      ../../../../shared/home-manager/development-full
    ];
    home.stateVersion = "24.05";
  };

  # Allow passwordless sudo for easy use. We don't have to be too worried about wrecking the system.
  security.sudo.extraRules = [
    {
      users = ["linus"];
      commands = ["ALL"];
    }
  ];
}
