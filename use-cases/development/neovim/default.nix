# This file contains the HM configuration options for Neovim.

{ pkgs, lib, ... }:

{
  imports =
    [
      ./lsp.nix
      ./filetype.nix
    ];

  programs.neovim = {
    enable = true;

    # Typing `vi`, `vim`, or `vimdiff` will also run neovim.
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  # Set Neovim as the default editor.
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.VISUAL = "nvim";

  # Use neovim as man pager.
  home.sessionVariables.MANPAGER = "nvim +Man!";
}

# vi: foldmethod=marker
