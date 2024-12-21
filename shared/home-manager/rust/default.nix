# This module configures development tools for Rust.
{pkgs, ...}: {
  home.packages = with pkgs; [
    rustc
    cargo
  ];

  programs.neovim.extraLuaConfig = ''
    require("lspconfig")["rust_analyzer"].setup({
      cmd = { "${pkgs.rust-analyzer}/bin/rust-analyzer" },
    })
  '';
}
