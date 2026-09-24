# This module sets up Obsidian for my uni notes. They are synced with syncthing.
{pkgs, ...}: {
  programs.obsidian = {
    enable = true;

    defaultSettings = {
      communityPlugins = with pkgs.obsidianPlugins; [
      ];

      hotkeys = {
        "editor:insert-link" = []; # Unmap default CMD+K shortcut. I always confuse it with searching.
        "switcher:open" = [
          # Instead, map it to the quick switcher.
          {
            "modifiers" = ["Mod"];
            "key" = "O";
          }
          {
            "modifiers" = ["Mod"];
            "key" = "K";
          }
        ];
      };
    };

    vaults."AU" = {
      enable = true;
      target = "Sync/obsidian"; # NOTE: Must match syncthing config
    };
  };
}
