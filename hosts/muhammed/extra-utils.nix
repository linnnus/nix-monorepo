# This HM module adds extra utilities specific to this host.
{pkgs, ...}: let
  # Set some default options
  xkcdpass' = pkgs.writeShellScriptBin "xkcdpass" ''
    ${pkgs.xkcdpass}/bin/xkcdpass --delimiter="" --case capitalize --numwords=5 "$@"
  '';
in {
  home.packages = with pkgs; [
    imagemagick
    ffmpeg_6-full

    # Generating passwords
    xkcdpass'
  ];
}
