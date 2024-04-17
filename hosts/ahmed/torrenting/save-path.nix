{pkgs,lib,config,...}: let
  downloadPath = "/srv/media/";

  categories = [ "Movies" "Anime Movies" "Anime Series" "Series" "Miscellaneous" ];
in {
  # Create the directory to which media will be downloaded. This will be used
  # by qBittorent to hold files and Jellyfin will serve from it.
  systemd.tmpfiles.rules = let
    user = config.services.qbittorrent.user;
    group = config.services.qbittorrent.group;
  in
    map (category: "d ${lib.strings.escapeC [" "] "${downloadPath}/${category}"} 0755 ${user} ${group}") categories;

  # Configure qBittorrent to use the correct save path.
  services.qbittorrent.settings = {
      BitTorrent = {
        "Session\\DefaultSavePath" = assert builtins.elem "Miscellaneous" categories; "${downloadPath}/Miscellaneous";
        "Session\\TempPath" = "${config.services.qbittorrent.profile}/qBittorrent/temp";
        "Session\\TempPathEnabled" = true;
      };
      Preferences = {
        # Again??
        "Downloads\\SavePath" = downloadPath;
      };
  };

  # Create categories for qBittorrent with correct save paths.
  # WARNING: qBittorrent does NOT like it when you change the categories used by active torrents.
  systemd.services.qbittorrent.unitConfig = {
    Requires = ["qbittorrent-create-categories.service"];
    After = ["qbittorrent-create-categories.service"];
  };
  systemd.services.qbittorrent-create-categories = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      User = config.services.qbittorrent.user;
      Group = config.services.qbittorrent.group;
      ExecStart = let
        categoriesJson = lib.genAttrs categories (c: { "save_path" = "${downloadPath}/${c}"; });
        categoriesFile = (pkgs.formats.json {}).generate "categories.json" categoriesJson;
        categoriesPath = "${config.services.qbittorrent.profile}/qBittorrent/config/categories.json";
      in pkgs.writeShellScript "qbittorrent-create-categories.sh" ''
        ln -s -f ${categoriesFile} ${categoriesPath}
      '';
    };
  };

  # WARNING: Jellyfin has been manually configured to serve from the correct download paths.
}
