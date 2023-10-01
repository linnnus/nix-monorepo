{ python3
, fetchFromGitHub
, writeShellScriptBin
}:

let
  icalevents = ps: ps.buildPythonPackage rec {
    pname = "icalevents";
    version = "0.1.27";

    src = fetchFromGitHub {
      owner = "jazzband";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-vSYQEJFBjXUF4WwEAtkLtcO3y/am00jGS+8Vj+JMMqQ=";
    };

    doCheck = false;

    propagatedBuildInputs = with ps; [
      httplib2
      datetime
      icalendar
    ];
  };
  python3' = python3.withPackages (ps: with ps; [
    pytz
    requests
    python-dotenv
    (icalevents ps)
  ]);
  src = fetchFromGitHub {
    owner = "linnnus";
    repo = "duksebot";
    rev = "24634ab7459d913aea00c2e6d77f916607834ee4";
    hash = "sha256-+tbC7Z3oewBTyE6wTpUocL+6oWjCRAsqauBLTIOVBUY=";
  };
in
writeShellScriptBin "duksebot"
  ''
    exec ${python3'}/bin/python3 ${src}/script.py
  ''
