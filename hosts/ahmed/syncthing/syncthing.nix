# This module sets up syncthing on the server. It's very important because
# muhammed and boox-tablet seldom are online on the same network at the same
# time.
{config, ...}: {
  services.syncthing = {
    enable = true;

    key = config.age.secrets.syncthing-key.path;
    cert = config.age.secrets.syncthing-cert.path;

    settings = {
      folders = {
        "ebooks" = {
          label = "E-books";
          path = "~/Synced ebooks"; # Recall that `~syncthing` is `/var/lib/syntching`.
          copyOwnershipFromParent = true;
          devices = ["muhammed" "boox-tablet"];
        };

        "obsidian" = {
          label = "Obsidian";
          path = "~/Obsidian"; # Recall that `~syncthing` is `/var/lib/syntching`.
          devices = ["muhammed" "iphone"];
        };
      };

      devices = {
        boox-tablet.id = "SFQMOCB-TPRTXLD-WDL3REL-2XINQDR-3PZQ5IT-KX4PGXX-2VJO3JZ-2K2XNQ3";
        muhammed.id = "ZLKZCO5-K3GX3S6-PTLB5B6-ETRBPQT-6ZCKHYV-FXQNDPI-CGYRSO4-NIRPQAY";
        iphone.id = "EUXRCHL-WNE54DD-WK4GQED-TI3NC66-PHFITO7-MVEYLZE-34WBW6M-ZP37FAT";
      };
    };
  };

  age.secrets.syncthing-key.file = ../../../secrets/syncthing-keys/ahmed/key.pem.age;
  age.secrets.syncthing-cert.file = ../../../secrets/syncthing-keys/ahmed/cert.pem.age;
}
