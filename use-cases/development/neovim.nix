
# This file contains the HM configuration options for Neovim for the user
# 'linus'. Don't know him.

{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;

    # Wrap neovim with LSP dependencies.
    # TODO: Build fails with permission error. What? I hate computers...
    # package =
    #   let
    #     base = pkgs.neovim-unwrapped;
    #     deps = with pkgs; [ pyright ];
    #     neovim' = pkgs.runCommandLocal "neovim-with-deps" {
    #       buildInputs = [ pkgs.makeWrapper ];
    #     } ''
    #       mkdir $out
    #       # Link every top-level folder from pkgs.hello to our new target
    #       ln -s ${base}/* $out
    #       # Except the bin folder
    #       rm $out/bin
    #       mkdir $out/bin
    #       # We create the bin folder ourselves and link every binary in it
    #       ln -s ${base}/bin/* $out/bin
    #       # Except the nvim binary
    #       rm $out/bin/nvim
    #       # Because we create this ourself, by creating a wrapper
    #       makeWrapper ${base}/bin/nvim $out/bin/nvim \
    #         --prefix PATH : ${lib.makeBinPath deps}
    #     '';
    #   in
    #     neovim';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local lspconfig = require("lspconfig");
          lspconfig.pyright.setup { }
        '';
      }
    ];

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
