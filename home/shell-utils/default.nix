# This module adds some common shell utilities to my home managed environment.
{pkgs, ...}: let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in {
  home.packages = with pkgs;
    [
      human-sleep
      ripgrep
      jc
      jq
    ]
    ++ lib.optionals isLinux [
      file # File is not included in NixOS, but *is* included in Darwin.
    ]
    ++ lib.optionals isDarwin [
      pbv
      trash
      disable-sleep
    ];
}
