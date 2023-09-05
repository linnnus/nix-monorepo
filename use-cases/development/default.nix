{ config, lib, ... }:

{
  imports =
    [
      ./git
      ./neovim
      ./zsh # TODO: move to sysadmin?
    ];
}
