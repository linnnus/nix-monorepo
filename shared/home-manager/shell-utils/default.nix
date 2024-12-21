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
      nowrap
      echoargs
    ]
    ++ lib.optionals isLinux [
      file # File is not included in NixOS, but *is* included in Darwin.
    ]
    ++ lib.optionals isDarwin [
      pbv
      trash
      disable-sleep

      # Unlike the `stat` command on Linux (from coreutils or whatever), OSX's
      # `stat` does not automatically use the nicer format when stdout is a
      # sterminal.
      (pkgs.writeShellScriptBin "stat" ''
        if [ -t 1 ]; then
          /usr/bin/stat -x "$@"
        else
          /usr/bin/stat "$@"
        fi
      '')
    ];
}
