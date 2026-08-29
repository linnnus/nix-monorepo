# This module sets up Obsidian for my uni notes. They are synced with syncthing.
{pkgs, ...}: let
  vaultPathRelative = "Sync/obsidian";
in {
  programs.obsidian = {
    enable = true;

    defaultSettings = {
      communityPlugins = with pkgs.obsidianPlugins; [
        obsidian-latex-suite
      ];
    };

    vaults."AU" = {
      enable = true;
      target = vaultPathRelative;
    };
  };

  services.syncthing = {
    settings = {
      folders = {
        "obsidian" = {
          label = "Obsidian";
          # This should be outside one of the protected folders (i.e.
          # Documents, Pictures, etc.), as these require additional permissions
          # than just u=r+w.
          path = "~/${vaultPathRelative}";
          copyOwnershipFromParent = true;
          # FIXME: if we rely on ahmed being defined, we should import the defining module.
          devices = ["ahmed"]; # Already defined in syncthing module
        };
      };
    };
  };
}
