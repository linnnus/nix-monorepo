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
    rev = "0092e752610ec00b5080269721666d1b4c258119";
    hash = "sha256-fGVULOdV1EWXMTJor0MqCYQlTFMUw5m7HOwdmqxViEM=";
  };
in
writeShellScriptBin "duksebot"
  ''
    exec ${python3'}/bin/python3 ${src}/script.py
  ''
