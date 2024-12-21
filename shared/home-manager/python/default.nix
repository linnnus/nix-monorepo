# This module configures development tools for Python.
{pkgs, ...}: {
  home.packages = with pkgs; [
    (python311Full.withPackages (ps:
      with ps; [
        virtualenv
        tkinter
      ]))
  ];

  programs.neovim.extraLuaConfig = ''
    require("lspconfig")["pyright"].setup({
      cmd = { "${pkgs.pyright}/bin/pyright-langserver", "--stdio" },
    })
  '';
}
