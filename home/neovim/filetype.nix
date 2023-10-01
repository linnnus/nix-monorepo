# This module configures various syntax/filetype plugins for Neovim.
{pkgs, ...}: let
  vim-noweb = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-noweb";
    version = "26-08-2023"; # day of retrieval
    src = pkgs.fetchzip {
      url = "https://metaed.com/papers/vim-noweb/vim-noweb.tgz";
      hash = "sha256-c5eUZiKIjAfjJ33l821h5DjozMpMf0CaK03QIkSUfxg=";
    };
  };
in {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-nix
    vim-noweb
  ];
}
