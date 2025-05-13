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
          lable = "Ebooks";
          path = "~/Synced ebooks"; # Recall that `~syncthing` is `/var/lib/syntching`.
          copyOwnershipFromParent = true;
          devices = ["muhammed" "boox-tablet"];
        };
      };

      devices = {
        boox-tablet.id = "SFQMOCB-TPRTXLD-WDL3REL-2XINQDR-3PZQ5IT-KX4PGXX-2VJO3JZ-2K2XNQ3";
        muhammed.id = "ZLKZCO5-K3GX3S6-PTLB5B6-ETRBPQT-6ZCKHYV-FXQNDPI-CGYRSO4-NIRPQAY";
      };
    };
  };

  age.secrets.syncthing-key.file = ../../../secrets/syncthing-keys/ahmed/key.pem.age;
  age.secrets.syncthing-cert.file = ../../../secrets/syncthing-keys/ahmed/cert.pem.age;
}
