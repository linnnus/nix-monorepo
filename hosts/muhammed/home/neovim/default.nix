# Once again we extend the global configuration defined in `home/neovim/` with
# some stuff specific to this host (mainly development stuff).
{...}: {
  imports = [
    ./lsp.nix
    ./filetype.nix
  ];
}
