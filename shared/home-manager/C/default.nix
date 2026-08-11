# This module configures development tools for C.
{pkgs, ...}: let
  isLinux = pkgs.stdenv.isLinux;

  llvmPackages' = pkgs.unstable.llvmPackages_22;
in {
  home.packages = with pkgs;
    [
      llvmPackages'.clang
      llvmPackages'.clang-manpages
      man-pages-posix
      cscript
    ]
    ++ lib.optionals isLinux [
      man-pages
    ];

  programs.neovim.initLua = ''
    -- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
    local function switch_source_header(bufnr, client)
      local method_name = 'textDocument/switchSourceHeader'
      if not client or not client:supports_method(method_name) then
        return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
      end
      local params = vim.lsp.util.make_text_document_params(bufnr)
      client:request(method_name, params, function(err, result)
        if err then
          error(tostring(err))
        end
        if not result then
          vim.notify('corresponding file cannot be determined')
          return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
      end, bufnr)
    end

    vim.lsp.config("clangd", {
      cmd = { "${llvmPackages'.clang-tools}/bin/clangd", "--background-index", "--clang-tidy" },
      on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>s", function()
          switch_source_header(bufnr, client)
        end, {
          noremap=true,
          silent=true,
          buffer=bufnr,
        })
      end,
    })
    vim.lsp.enable("clangd")
  '';
}
