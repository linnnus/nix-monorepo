{
  writeTextFile,
  python3,
  lib,
}:
writeTextFile {
  name = "nowrap";

  text = ''
    #!${python3.interpreter}

    import sys
    import os

    cols = os.get_terminal_size().columns

    for line in sys.stdin:
        line = line.removesuffix("\n")
        print(line[:cols])
  '';
  executable = true;
  destination = "/bin/nowrap";

  meta = with lib; {
    description = "Truncates lines from stdin such that they are no wider than the terminals width";
    mainProgram = "nowrap";
  };
}
