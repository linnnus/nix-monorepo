# This module contains all ZSH configuration related to the editing experience (e.g. setting VI mode).
{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.strings) concatStringsSep;
  inherit (lib.attrsets) catAttrs;

  plugins = [
    {
      name = "zsh-vi-mode-cursor";
      src = pkgs.fetchFromGitHub {
        owner = "Buckmeister";
        repo = "zsh-vi-mode-cursor";
        rev = "fa7cc0973ee71636e906e25e782d0aea19545d60";
        hash = "sha256-j73M4bvAoHWt5Wwg47hM0p5Or74x/3btTOPnI22SqG8=";
      };
    }
  ];
in {
  programs.zsh = {
    # VIM! VIM! VIM!
    defaultKeymap = "viins";

    plugins = map (p: removeAttrs p ["config"]) plugins;

    initExtra = ''
      # Set up external editing by pressing '!' in normal mode.
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd '!' edit-command-line

      # Plugins config.
      ${concatStringsSep "\n" (catAttrs "config" plugins)}
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
