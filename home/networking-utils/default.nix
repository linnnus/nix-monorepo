# This module adds some networking utilities to my home managed environment.
{pkgs, ...}: {
  home.packages = with pkgs;
    [
      nmap
      inetutils
      socat
    ]
    ++ lib.optional (!pkgs.stdenv.isDarwin) netcat;
}
