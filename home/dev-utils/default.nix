{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      # smol utils
      nodePackages_latest.nodemon
      rlwrap
      socat

      # heavy hitters
      imagemagick
      ffmpeg_6-full

      # interpreaters
      cling
      deno
      (python311Full.withPackages (ps:
        with ps; [
          virtualenv
          tkinter
        ]))
      tcl-8_6
      crystal

      # Clojure ecosystem
      clojure
      leiningen
    ]
    ++ lib.optional pkgs.stdenv.isDarwin trash;

  # Add system manual pages to the search path on Darwin.
  home.sessionVariables.MANPATH = lib.optionalString pkgs.stdenv.isDarwin "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/share/man:/Applications/Xcode.app/Contents/Developer/usr/share/man:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man:$MANPATH";

  # Add local executables/scripts to path.
  home.sessionVariables.PATH = "$HOME/.local/bin:$PATH";
}
