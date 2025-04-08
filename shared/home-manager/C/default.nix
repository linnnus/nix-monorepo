# This module configures development tools for C.
{pkgs, ...}: let
  isLinux = pkgs.stdenv.isLinux;
in {
  home.packages = with pkgs; [
    clang
    clang-manpages
    man-pages-posix
    cscript
  ]
  ++ lib.optionals isLinux [
    man-pages
  ];

  programs.neovim.extraLuaConfig = ''
    require("lspconfig")["clangd"].setup({
      cmd = { "${pkgs.clang-tools}/bin/clangd", "--background-index", "--clang-tidy" },
      on_attach = function(_, bufnr)
        vim.keymap.set("n", "<leader>s", function()
          vim.cmd [[ClangdSwitchSourceHeader]]
        end, {
          noremap=true,
          silent=true,
          buffer=bufnr,
        })
      end,
    })
  '';
}
