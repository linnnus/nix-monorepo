# This module configures development tools for Rust.
{pkgs, ...}: {
  home.packages = with pkgs; [
    rustc
    cargo
  ];

  programs.neovim.initLua = ''
    vim.lsp.config("rust_analyzer", {
      cmd = { "${pkgs.rust-analyzer}/bin/rust-analyzer" },
    })
    vim.lsp.enable("rust_analyzer")
  '';
}
