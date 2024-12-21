# This part (module) of my home manager configuration adds some random utilities.
{pkgs, ...}: let
  # Set some default options
  xkcdpass' = pkgs.writeShellScriptBin "xkcdpass" ''
    ${pkgs.xkcdpass}/bin/xkcdpass --delimiter \'\' --capitalize --numwords=4 "$@"
  '';
in {
  home.packages = [
    # Generating passwords
    xkcdpass'
  ];
}
