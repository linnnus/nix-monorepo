# This module configures development tools for Svelte.
{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-svelte
    ];

    initLua = ''
      vim.lsp.config("svelte", {
        cmd = { "${pkgs.svelte-language-server}/bin/svelteserver", "--stdio" },
        root_markers = {"package.json", ".git", "deno.json", "deno.jsonc"},
      })
      vim.lsp.enable("svelte")
    '';
  };
}
