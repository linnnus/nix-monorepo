# This module configures development tools for Svelte.
{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-svelte
    ];

    extraLuaConfig = ''
      local util = require("lspconfig.util")
      require("lspconfig")["svelte"].setup({
        cmd = { "${pkgs.nodePackages_latest.svelte-language-server}/bin/svelteserver", "--stdio" },
        root_dir = util.root_pattern("package.json", ".git", "deno.json", "deno.jsonc"),
      })
    '';
  };
}
