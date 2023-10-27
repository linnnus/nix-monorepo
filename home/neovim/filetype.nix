# This module configures various syntax/filetype plugins for Neovim.
{pkgs, ...}: {
  programs.neovim.plugins = with pkgs;
  with vimPlugins; [
    # Filetype plugins
    vim-nix
    vim-noweb
    vim-janet
    vim-crystal
  ];
}
