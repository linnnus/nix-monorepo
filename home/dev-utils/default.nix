{ pkgs, lib, ... }:

{
  home.packages =
    with pkgs; [
      cling
      deno
      (python311Full.withPackages (ps: with ps; [
        virtualenv
        tkinter
      ]))
      imagemagick
      nodePackages_latest.nodemon
      rlwrap
      tcl-8_6
    ] ++ lib.optional pkgs.stdenv.isDarwin trash;

    home.sessionVariables.MANPATH = lib.optionalString pkgs.stdenv.isDarwin "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/share/man:/Applications/Xcode.app/Contents/Developer/usr/share/man:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man:$MANPATH";
}
