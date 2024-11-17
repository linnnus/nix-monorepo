{
  writeTextFile,
  python3,
  lib,
}:
writeTextFile {
  name = "echoargs";

  text = ''
    #!${python3.interpreter}

    import sys
    import json

    for i, arg in enumerate(sys.argv):
        print(f"argv[%d] = %s" % (i, json.dumps(arg)))
  '';
  executable = true;
  destination = "/bin/echoargs";

  meta = with lib; {
    description = "Prints command-line arguments for debugging";
    mainProgram = "echoargs";
  };
}
