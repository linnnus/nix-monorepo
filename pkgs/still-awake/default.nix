{
  stdenv,
  python3,
  lib,
}: let
  # Needs python interpreter with tkinter support.
  python3' = python3.withPackages (ps: [ps.tkinter]);
in
  stdenv.mkDerivation {
    pname = "still-awake";
    version = "10-09-2023";

    src = builtins.readFile ./still_awake.py;
    passAsFile = ["buildCommand" "src"];

    # Building basically boils down to writing source to a file
    # and making it executable.
    buildCommand = ''
      mkdir -p $out/bin

      echo "#!${python3'.interpreter}" >$out/bin/still-awake

      if [ -e "$srcPath" ]; then
        cat "$srcPath" >>$out/bin/still-awake
      else
        echo -n "$src" >>$out/bin/still-awake
      fi

      chmod +x $out/bin/still-awake
    '';

    # It doesn't make sense to do this remotely.
    preferLocalBuild = true;
    allowSubstitute = false;

    meta = with lib; {
      description = "Small program which shuts down Mac, if user is asleep";
      license = licenses.unlicense;
      platforms = platforms.darwin;
    };
  }
