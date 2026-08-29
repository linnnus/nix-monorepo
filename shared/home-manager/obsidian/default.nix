# This module sets up Obsidian for my uni notes. They are synced with syncthing.
{pkgs, ...}: {
  programs.obsidian = {
    enable = true;

    defaultSettings = {
      communityPlugins = with pkgs.obsidianPlugins; [
        obsidian-latex-suite
      ];
    };

    vaults."AU" = {
      enable = true;
      target = "Sync/obsidian"; # NOTE: Must match syncthing config
    };
  };
}
