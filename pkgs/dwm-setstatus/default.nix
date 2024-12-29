{
  stdenv,
  lib,
  libX11,
}:
stdenv.mkDerivation {
  pname = "human-sleep";
  version = "16-11-2024"; # Date of last change

  src = ./.;
  nativeBuildInputs = [ libX11 ];
  buildPhase = ''
    cc dwm-setstatus.c -lX11 -o dwm-setstatus
  '';

  # TODO: Run check phase: `cscript -DTEST human-sleep.c`

  installPhase = ''
    mkdir -p $out/bin
    mv dwm-setstatus $out/bin
  '';

  meta = with lib; {
    homepage = "https://wiki.archlinux.org/title/Dwm#Conky_statusbar";
    description = "Updates DWM status bar for every line on stdin";
    mainProgram = "dwm-setstatus";
  };
}
