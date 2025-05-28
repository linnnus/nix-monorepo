{
  lib,
  swiftPackages,
  xcbuild,
  fetchFromGitHub,
}:
swiftPackages.stdenv.mkDerivation {
  pname = "pbv";
  version = "31-08-2020"; # date of commit

  src = fetchFromGitHub {
    owner = "chbrown";
    repo = "macos-pasteboard";
    rev = "6d58ddcff833397b15f4435e661fc31a1ec91321";
    hash = "sha256-6QpvIPy259d7BtA6s2NxS5JqiBPngPwgVgJl509btuY=";
  };

  buildInputs = [
    swiftPackages.swift
    xcbuild
  ];

  installPhase = ''
    mkdir -p $out/bin
    make prefix=$out install
  '';

  meta = with lib; {
    description = "Like OS X's built-in pbpaste but more flexible and raw";
    homepage = "https://github.com/chbrown/macos-pasteboard";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
