# This module adds some common shell utilities to my home managed environment.
{pkgs, ...}: {
  home.packages = with pkgs;
    [
      human-sleep
      ripgrep
      jc
      jq
    ]
    ++ lib.optionals (pkgs.stdenv.isLinux) [
      file # File is not included in NixOS, but *is* included in Darwin.
    ]
    ++ lib.optionals (pkgs.stdenv.isDarwin) [
      pbv
      trash
    ];
}
