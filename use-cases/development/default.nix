{ config, lib, ... }:

{
  imports =
    [
      ./git.nix
      ./neovim.nix
      ./zsh.nix
    ];
}
