# This module defines the contents of `~/.config/git/ignore`. It fetches the
# templates for different gitignores and compiles them into one.
{
  pkgs,
  lib,
  ...
}: let
  gitignore = ignores:
    pkgs.stdenv.mkDerivation {
      name = (lib.concatStringsSep "+" ignores) + ".gitignore";

      src = pkgs.fetchFromGitHub {
        owner = "toptal";
        repo = "gitignore";
        rev = "7e72ecd8af69b39c25aedc645117f0dc261cedfd";
        hash = "sha256-Ln3w6wx+pX4UFLY2gGJGax2/nxgp/Svrn0uctSIRdEc=";
      };

      inherit ignores;
      buildPhase = ''
        for i in $ignores; do
          cat ./templates/$i.gitignore >>$out
        done
      '';
    };

  targets =
    [
      "Node"
      "Deno"
      "C"
    ]
    ++ (lib.optional pkgs.stdenv.isDarwin "MacOS")
    ++ (lib.optional pkgs.stdenv.isLinux "Linux");
in {
  xdg.configFile."git/ignore".source = gitignore targets;
}
