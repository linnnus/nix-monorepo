# This module sets up LSP server configurations for Neovim. It is waaay
# overcomplicated as it kind of turned into an experiment in generating Lua
# code from a Nix attrset.

{ pkgs, lib, ... }:

let
  servers = {
    pyright.cmd = [ "${pkgs.pyright}/bin/pyright-langserver" ];
    rnix.cmd = [ "${pkgs.rnix-lsp}/bin/rnix-lsp" ];
  };
  defaultConfig = {
    flags.debounce_text_changes = 150;
  };
  combinedConfig = lib.mapAttrs (name: value: value // defaultConfig) servers;

  nixToLua = s:
    if builtins.isAttrs s then
      let
        renderAttr = name: value: "[ [==========[" + name + "]==========] ] = " + (nixToLua value);
        attrsList = map (name: renderAttr name s.${name}) (lib.attrNames s);
        attrsListStr = lib.concatStringsSep ", " attrsList;
      in
      "{ ${attrsListStr} }"
    else if builtins.isList s then
      "{ " + (lib.concatStringsSep ", " (map nixToLua s)) + " }"
    else if builtins.isString s then
      # Oh boy I sure hope `s` doesn't contain "]==========]".
      "[==========[" + s + "]==========]"
    else if builtins.isInt s || builtins.isFloat s then
      toString s
    else
      throw "Cannot convert ${builtins.typeOf s} to Lua value!";
  combinedConfigStr = nixToLua combinedConfig;
in
{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.nvim-lspconfig;
      type = "lua";
      config = ''
        local lspconfig = require("lspconfig")
        local util = require("lspconfig.util")

        -- Mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        local opts = { noremap=true, silent=true }
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(client, bufnr)
        	-- Enable completion triggered by <c-x><c-o>
        	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        	-- Mappings.
        	-- See `:help vim.lsp.*` for documentation on any of the below functions
        	local bufopts = { noremap=true, silent=true, buffer=bufnr }
        	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        	vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        	vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        	vim.keymap.set('n', '<leader>wl', function()
        		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        	end, bufopts)
        	vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
        	vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
        	vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
        	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        	vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
        	vim.keymap.set('n', '<leader>s', function() vim.cmd[[ClangdSwitchSourceHeader]] end, bufopts)
        end

        -- Use a loop to conveniently call 'setup' on multiple servers and
        -- map buffer local keybindings when the language server attaches
        local servers = ${combinedConfigStr};
        for server, config in pairs(servers) do
        	config.on_attach = on_attach; -- inject lua event handler; not elegant!
        	lspconfig[server].setup(config)
        end
      '';
    }
  ];
}
