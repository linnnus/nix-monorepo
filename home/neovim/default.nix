# This file contains the HM configuration options for Neovim.

{ pkgs, lib, ... }:

{
  imports =
    [
      ./lsp.nix
      ./filetype.nix
      ./completion.nix
      ./plugins.nix
    ];

  programs.neovim = {
    enable = true;

    # Import my existing config. I've been working on this for years and when
    # my enthusiasm for Nix eventually dies off, I want to take it with me.
    extraConfig = builtins.readFile ./init.vim;

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
