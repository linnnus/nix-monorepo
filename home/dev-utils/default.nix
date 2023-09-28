{ pkgs, lib, ... }:

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

    home.sessionVariables.MANPATH = lib.mkIf pkgs.stdenv.isDarwin "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/share/man:/Applications/Xcode.app/Contents/Developer/usr/share/man:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man:$MANPATH";
}