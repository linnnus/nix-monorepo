# This module configures development tools for Gleam.
{
  pkgs,
  lib,
  ...
}: let
  # Gleam shells out to erlang and rebar during building apparently.
  gleam' = pkgs.unstable.gleam.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
    postInstall =
      (old.postInstall or "")
      + ''
        wrapProgram $out/bin/gleam \
          --prefix PATH  : ${
          lib.makeBinPath (with pkgs; [
            erlang
            rebar3
          ])
        }
      '';
  });
in {
  home.packages = [gleam'];

  programs.neovim.initLua = ''
    vim.lsp.config("gleam", {
      cmd = { "${gleam'}/bin/gleam", "lsp" },
    })
  '';

  programs.neovim.plugins = with pkgs.vimPlugins; [
    nvim-treesitter-parsers.gleam
  ];
}
