{
  config,
  flakeInputs,
  ...
}: {
  # Until nix-community/home-manager@45c07fc becomes part of the channel we're
  # following, I've just manually included it here. When that time comes, the
  # module should be removed.
  imports = let
    home-manager' = builtins.fetchGit {
      url = "https://github.com/nix-community/home-manager.git";
      rev = "45c07fcf7d28b5fb3ee189c260dee0a2e4d14317";
    };
  in [
    "${home-manager'}/modules/services/syncthing.nix"
    flakeInputs.agenix.homeManagerModules.age
  ];
  disabledModules = ["services/syncthing.nix"];

  services.syncthing = {
    enable = true;

    key = config.age.secrets.syncthing-key.path;
    cert = config.age.secrets.syncthing-cert.path;

    settings = {
      folders = {
        "ebooks" = {
          lable = "Ebooks";
          # This should be outside one of the protected folders (i.e.
          # Documents, Pictures, etc.), as these require additional permissions
          # than just u=r+w.
          path = "~/Sync/ebooks";
          copyOwnershipFromParent = true;
          devices = ["ahmed" "boox-tablet"];
        };
      };

      devices = {
        boox-tablet.id = "SFQMOCB-TPRTXLD-WDL3REL-2XINQDR-3PZQ5IT-KX4PGXX-2VJO3JZ-2K2XNQ3";
        ahmed.id = "5ESNFDE-D7UZTFN-GNZ56QP-CY3TUCN-OJSNFCN-UVKVLQR-UTIJZ4W-2ZDVCQG";
      };
    };
  };

  # We store the keys as part of the configuration since the device id is based
  # on the key and we don't want that to change.
  age.secrets.syncthing-key.file = ../../secrets/syncthing-keys/muhammed/key.pem.age;
  age.secrets.syncthing-cert.file = ../../secrets/syncthing-keys/muhammed/cert.pem.age;

  # Override the launchd service created by the HMs syncthing module to save logs.
  # We can't write to /var/logs as this is a user agent running has non-root user.
  launchd.agents.syncthing.config = rec {
    StandardOutPath = "/tmp/syncthing.log";
    StandardErrorPath = StandardOutPath;
  };
}
