# This module defines Home Manager configuration options for the 'sysadmin' use
# case. That is, basic system administration.

{ pkgs, super, lib, ... }:

{
  home.packages = with pkgs; [
    tree
    jc
    jq
    vim
    comma
  ];

  # basic qol shell aliases
  home.shellAliases = {
    "mv" = "mv -i";
    "rm" = "rm -i";
    "cp" = "cp -i";
    "ls" = "ls -A --color=auto";
    "grep" = "grep --color=auto";
  };
}
