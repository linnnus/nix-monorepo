{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  ffmpeg,
  variant ?
    if (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64)
    then "aarch64"
    else if (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64)
    then "x86_64"
    else throw "Cannot guess variant",
}:
assert builtins.elem variant [
  "aarch64"
  "x86_64"
];
  stdenv.mkDerivation rec {
    pname = "TagStudio-bin-${variant}";
    version = "9.5.3";

    src = fetchurl {
      url = "https://github.com/TagStudioDev/TagStudio/releases/download/v${version}/tagstudio_macos_${variant}.tar.gz";
      hash =
        {
          "aarch64" = "sha256-fRuBhtMpZ7Ilec1JRDxPUup6qaHWTrGqTIV67d5ach0=";
          "x86_64" = throw "idfk i didn't do that";
        }.${
          variant
        };
    };

    # The tarball contains a single `.app` directory. Don't `cd` into it.
    sourceRoot = ".";

    # PyInstaller works by embedding python code in an executable which we
    # obviously don't want to strip.
    dontStrip = true;

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{Applications,bin}/
      mv TagStudio.app $out/Applications/

      makeWrapper \
        "$out/Applications/TagStudio.app/Contents/MacOS/tagstudio" \
        "$out/bin/tagstudio"

      runHook postInstall
    '';

    postInstall = ''
      wrapProgram $out/Applications/TagStudio.app/Contents/MacOS/tagstudio \
        --prefix PATH : ${lib.makeBinPath [ffmpeg]}
    '';

    meta = {
      description = "A User-Focused Photo & File Management System; binary release packaged for ";
      platforms = with lib.systems.inspect;
        patternLogicalAnd patterns.isDarwin
        {
          "aarch64" = patterns.isAarch64;
          "x86_64" = patterns.isx86_64;
        }.${
          variant
        };
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = "tagstudio";
    };
  }
