# This HM module adds extra utilities specific to this host.
{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    # A "real" browser is too heavy.
    elinks

    # For watching movies.
    ffmpeg

    lsof
    lshw
    psmisc
  ];
}
