{
  config,
  flakeInputs,
  ...
}: {
  # Until nix-community/home-manager@45c07fc becomes part of the channel we're
  # following, I've just manually included it here. When that time comes, the
  # module should be removed.
  imports = [
    flakeInputs.agenix.homeManagerModules.age
  ];

  services.syncthing = {
    enable = true;

    key = config.age.secrets.syncthing-key.path;
    cert = config.age.secrets.syncthing-cert.path;

    settings = {
      folders = {
        "ebooks" = {
          label = "E-books";
          # This should be outside one of the protected folders (i.e.
          # Documents, Pictures, etc.), as these require additional permissions
          # than just u=r+w.
          path = "~/Sync/ebooks";
          copyOwnershipFromParent = true;
          devices = ["ahmed" "boox-tablet"];
        };

        "obsidian" = {
          label = "Obsidian vault";
          path = "~/Sync/obsidian";
          devices = ["ahmed"];
          ignorePatterns = [
            # The `stignore` syntax is basically like `.gitignore`.
            # See: https://obsidian.md/help/data-storage
            # See: https://docs.syncthing.net/users/ignoring.html
            "/.obsidian/workspace.json"
            "/.obsidian/workspaces.json"
            "/.obsidian/workspace-mobile.json"
          ];
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
}
