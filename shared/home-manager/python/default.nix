# This module configures development tools for Python.
{pkgs, ...}: {
  home.packages = with pkgs; [
    (python312.withPackages (ps:
      with ps; [
        virtualenv
        tkinter
      ]))
  ];

  programs.neovim.initLua = ''
    require("lspconfig")["pyright"].setup({
      cmd = { "${pkgs.pyright}/bin/pyright-langserver", "--stdio" },
    })
  '';
}
