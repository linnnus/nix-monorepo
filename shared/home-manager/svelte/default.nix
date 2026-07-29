# This module configures development tools for Svelte.
{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-svelte
    ];

    initLua = ''
      local util = require("lspconfig.util")
      require("lspconfig")["svelte"].setup({
        cmd = { "${pkgs.svelte-language-server}/bin/svelteserver", "--stdio" },
        root_dir = util.root_pattern("package.json", ".git", "deno.json", "deno.jsonc"),
      })
    '';
  };
}
