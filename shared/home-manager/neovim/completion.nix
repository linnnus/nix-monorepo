# This module sets up auto completion for Neovim.
{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # This is the actual completion engine.
    {
      plugin = nvim-cmp;
      type = "lua";
      config = ''
        local cmp = require("cmp")

        cmp.setup({
        	mapping = cmp.mapping.preset.insert({
        		["<C-b>"] = cmp.mapping.scroll_docs(-4),
        		["<C-f>"] = cmp.mapping.scroll_docs(4),
        		["<C-j>"] = cmp.mapping.select_next_item(),
        		["<C-k>"] = cmp.mapping.select_prev_item(),
        		["<C-Space>"] = cmp.mapping.complete(),
        		["<C-e>"] = cmp.mapping.abort(),
        		["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        	}),
        	sources = cmp.config.sources({
        		{ name = "nvim_lsp" },
        		{ name = "calc" },
        		{ name = "path" },
        		{ name = "buffer" },
        	}),
        	-- disable completion in comments
        	enabled = function()
        		local context = require("cmp.config.context")
        		-- keep command mode completion enabled when cursor is in a comment
        		if vim.api.nvim_get_mode().mode == "c" then
        			return true
        		else
        			return not context.in_treesitter_capture("comment")
        			   and not context.in_syntax_group("Comment")
        		end
        	end
        })
      '';
    }
    # The following are plugins for the... completion plugin.
    cmp-nvim-lsp
    cmp-calc
    cmp-buffer
    cmp-path
  ];
}
