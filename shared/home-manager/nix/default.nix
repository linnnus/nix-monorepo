# This module configures development tools for Nix.
{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-nix
    ];

    extraLuaConfig = ''
      require("lspconfig")["nixd"].setup({
        cmd = { "${pkgs.nixd}/bin/nixd" },
      })
    '';
  };
}
