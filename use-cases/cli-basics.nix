# This module defines Home Manager configuration options for the 'sysadmin' use
# case. That is, basic system administration.

{ pkgs, super, lib, ... }:

{
  home.packages = with pkgs; [
    tree
    jc
    jq
    vim
  ];
}
