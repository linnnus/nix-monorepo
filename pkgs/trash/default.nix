{
  stdenv,
  fetchFromGitHub,
  perl534Packages,
  darwin,
  lib,
}:
stdenv.mkDerivation rec {
  name = "trash";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "ali-rantakari";
    repo = "trash";
    rev = "v${version}";
    sha256 = "sha256-vibUimY15KTulGVqmmTGtO/+XowoRHykcmL8twdgebQ=";
  };
  patches = [./trash-dont-hardcode-arch.patch];
  buildInputs = [
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.ScriptingBridge
    perl534Packages.podlators
  ];

  outputs = ["out" "man"];

  buildPhase = ''
    make trash trash.1
  '';

  installPhase = ''
    mkdir -p $out/bin $man/share/man/man1
    mv trash $out/bin
    mv trash.1 $man/share/man/man1/trash.1
    # I like to alias as del because trash is so hard spell
    ln -s $out/bin/trash $out/bin/del
  '';

  meta = with lib; {
    description = "This is a small command-line program for OS X that moves files or folders to the trash.";
    homepage = "https://github.com/ali-rantakari/trash";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
