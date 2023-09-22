{ pkgs, ... }:

{
  home.packages =
    with pkgs; [
      cling
      deno
      imagemagick
      nodePackages_latest.nodemon
      rlwrap
      tcl-8_6
    ];
}
