# This module defines Home Manager configuration options for the 'sysadmin' use
# case. That is, basic system administration.

{ pkgs, super, lib, ... }:

let
  inherit (lib) optional;
in
{
  home.packages = with pkgs; [
    tree
    jc
    jq
    # is this not the right it is the one passed to home-manager not nixos ???? 'config'?
  ] ++ (optional (!super.my.use-cases.development.enable) vim);
}
