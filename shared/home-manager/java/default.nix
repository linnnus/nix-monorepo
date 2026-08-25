# This module configures development tools for Rust.
{pkgs, ...}: {
  home.packages = with pkgs; [
    openjdk
  ];

  programs.neovim.initLua = ''
    vim.lsp.config("jdtls", {
      cmd = { "${pkgs.jdt-language-server}/bin/jdtls" },
      root_markers = { 'build.gradle', 'build.gradle.kts', 'pom.xml', '.git' },
      filetypes = { 'java' },
    })
    vim.lsp.enable("jdtls")
  '';
}
