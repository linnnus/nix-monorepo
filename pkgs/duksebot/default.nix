{
  python3,
  fetchFromGitHub,
  writeShellScriptBin,
}: let
  icalevents = ps:
    ps.buildPythonPackage rec {
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
  python3' = python3.withPackages (ps:
    with ps; [
      pytz
      requests
      python-dotenv
      (icalevents ps)
    ]);
  src = fetchFromGitHub {
    owner = "linnnus";
    repo = "duksebot";
    rev = "69d45f62d1a3dce971f098dbcd5ee2b3ad0da7e5";
    hash = "sha256-4rkVnHY7WoB8A6PteulCfdlcJJJ91ez/oSatg5ujfPw=";
  };
in
  writeShellScriptBin "duksebot"
  ''
    exec ${python3'}/bin/python3 ${src}/script.py
  ''
