# This module configures development tools for Nix.
{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-nix
    ];

    initLua = ''
      vim.lsp.config("nixd", {
        cmd = { "${pkgs.nixd}/bin/nixd" },
      })
    '';
  };
}
