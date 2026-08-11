{
  writeShellApplication,
  writeTextFile,
  symlinkJoin,
  runtimeShell,
  lib,
  coreutils,
  python3,
}: let
  writePythonScript = {
    name,
    text,
    runtimeInputs ? [],
    runtimeEnv ? {},
    meta ? {},
    derivationArgs ? {},
    python ? python3,
    inheritPath ? true,
  }: let
    script = writeTextFile {
      name = name + ".py";
      inherit text;
    };
  in
    writeTextFile {
      inherit name meta derivationArgs;
      destination = "/bin/${name}";
      executable = true;
      text =
        ''
          #!${runtimeShell}
          set -o errexit -o nounset -o pipefail
        ''
        + lib.optionalString (runtimeEnv != null) (
          lib.concatMapAttrsStringSep "" (name: value: ''
            ${lib.toShellVar name value}
            export ${name}
          '')
          runtimeEnv
        )
        + lib.optionalString (runtimeInputs != [] || !inheritPath) ''
          export PATH="${
            lib.concatStringsSep ":" (
              (lib.optionals (runtimeInputs != []) [(lib.makeBinPath runtimeInputs)])
              ++ (lib.optionals inheritPath ["$PATH"])
            )
          }"
        ''
        + ''

          exec ${python.interpreter} ${lib.escapeShellArg script} "$@"
        '';
    };

  today = writeShellApplication {
    name = "today";
    runtimeInputs = [coreutils];
    text = ''
      exec date +%Y-%m-%d
    '';
  };

  # There's no reason to add runtimeInputs to this
  # derivation as it is intended to be invoked via git.
  git-pushall = writeShellApplication {
    name = "git-pushall";
    text = ''
      for remote in $(git remote); do
              echo '$ ' git push "$remote" "$@"
              git push "$remote" "$@"
      done
    '';
  };

  yargs = writePythonScript {
    name = "yargs";
    text = builtins.readFile ./yargs.py;
  };

  echoargs = writePythonScript {
    name = "echoargs";
    text = ''
      import sys
      import json

      for i, arg in enumerate(sys.argv):
          print(f"argv[%d] = %s" % (i, json.dumps(arg)))
    '';
    meta = {
      description = "Prints command-line arguments for debugging";
      mainProgram = "echoargs";
    };
  };

  nowrap = writePythonScript {
    name = "nowrap";
    text = ''
      import sys
      import os

      cols = os.get_terminal_size().columns

      for line in sys.stdin:
          line = line.removesuffix("\n")
          print(line[:cols])
    '';
    meta = {
      description = "Truncates lines from stdin such that they are no wider than the terminals width";
      mainProgram = "nowrap";
    };
  };
in
  symlinkJoin {
    name = "linus-utils";
    paths = [
      today
      git-pushall
      yargs
      echoargs
      nowrap
    ];
  }
