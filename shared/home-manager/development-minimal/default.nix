# This module pulls in other HM modules which together form a minimal
# development enviroment. It does so while taking care not to balloon the
# closure size too much.
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../zsh
    ../shell-utils

    ../git
    ../neovim
    ../networking-utils
  ];

  home.packages = with pkgs; [
    rlwrap
    devenv
  ];

  # Add system manual pages to the search path on Darwin.
  home.sessionVariables.MANPATH = lib.optionalString pkgs.stdenv.isDarwin "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/share/man:/Applications/Xcode.app/Contents/Developer/usr/share/man:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man:$MANPATH";

  # Add local executables/scripts to path.
  home.sessionVariables.PATH = "$HOME/.local/bin:$PATH";
}
