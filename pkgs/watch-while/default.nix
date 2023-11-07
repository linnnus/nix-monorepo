{
  zsh,
  mpv,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "watch-while";
  version = "0.1.0";

  src = ./watch-while.zsh;
  unpackPhase = ":";

  buildPhase = ''
    substituteAll $src ${pname}
    chmod +x ${pname}
  '';
  inherit zsh mpv;

  installPhase = ''
    mkdir -p $out/bin
    mv ${pname} $out/bin/
  '';
}
