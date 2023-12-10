{
  python3,
  fetchFromGitHub,
  writeShellScriptBin,
  languagetool,
}: let
  yalafi = python3.pkgs.buildPythonPackage rec {
    pname = "YaLafi";
    version = "1.4.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "torik42";
      repo = pname;
      rev = version;
      hash = "sha256-t+iVko04J4j0ULo7AJFhcf/iNVop91GGrpt/ggpQJZo=";
    };

    nativeBuildInputs = [
      python3.pkgs.setuptools-scm
    ];
  };

  python3-with-yalafi = python3.withPackages (ps: [yalafi]);
in
  writeShellScriptBin "yalafi-shell" ''
    ${python3-with-yalafi.interpreter} -m yalafi.shell --lt-command "${languagetool}"/bin/languagetool-commandline "$@"
  ''
