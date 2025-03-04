{...}: {
  # Until nix-community/home-manager@45c07fc becomes part of the channel we're
  # following, I've just manually included it here. When that time comes, the
  # module should be removed.
  imports = let
    home-manager' = builtins.fetchGit {
      url = "https://github.com/nix-community/home-manager.git";
      rev = "45c07fcf7d28b5fb3ee189c260dee0a2e4d14317";
    };
  in ["${home-manager'}/modules/services/syncthing.nix"];
  disabledModules = ["services/syncthing.nix"];

  services.syncthing = {
    enable = true;

    settings = {
      folders = {
        "ebooks" = {
          lable = "Ebooks";
          path = "~/Documents/Synced ebooks";
          copyOwnershipFromParent = true;
          devices = ["boox-tablet"];
        };
      };

      devices = {
        boox-tablet.id = "SFQMOCB-TPRTXLD-WDL3REL-2XINQDR-3PZQ5IT-KX4PGXX-2VJO3JZ-2K2XNQ3";
      };
    };
  };
}
