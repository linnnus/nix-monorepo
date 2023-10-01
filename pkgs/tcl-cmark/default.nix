{ tcl
, pkg-config
, autoreconfHook
, cmark-gfm
, fetchFromGitHub
, lib
}:

tcl.mkTclDerivation {
  pname = "tcl-cmark";
  version = "2022-03-15";

  src = fetchFromGitHub {
    owner = "apnadkarni";
    repo = "tcl-cmark";
    rev = "b8e203fe48f2b717365c5c58a2908019b2f36f8b";
    hash = "sha256-wXr/sDIh4o8l+21ALb7CDPnYsExr9p7IZ6Kg5tAOGHs=";
  };

  patches = [
    ./fix-gfm-extension-name.patch
  ];

  nativeBuildInputs = [ pkg-config autoreconfHook ];
  buildInputs = [ cmark-gfm ];

  meta = with lib; {
    description = "Tcl bindings to the cmark-gfm Github Flavoured CommonMark/Markdown library";
    homepage = "https://github.com/apnadkarni/tcl-cmark/";
    license = licenses.bsd3;
  };
}
