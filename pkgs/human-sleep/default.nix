{
  stdenv,
  lib,
}:
stdenv.mkDerivation {
  pname = "human-sleep";
  version = "16-11-2024"; # Date of last change

  src = ./.;
  buildPhase = ''
    cc human-sleep.c -Wall -Wextra -o human-sleep
  '';

  # TODO: Run check phase: `cscript -DTEST human-sleep.c`

  installPhase = ''
    mkdir -p $out/bin
    mv human-sleep $out/bin/human-sleep
    ln -s human-sleep $out/bin/hsleep
  '';

  meta = with lib; {
    description = "Variant of the classic 'sleep' command that accepts suffixed numbers like '5 minutes'";
    license = licenses.unlicense;
    mainProgram = "human-sleep";
  };
}
