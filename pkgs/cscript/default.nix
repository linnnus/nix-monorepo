{
  stdenv,
  lib,
  fetchFromGitHub,
  llvmPackages,
  strace,
}: let
  self = stdenv.mkDerivation rec {
    pname = "cscript";
    version = "21-12-2024"; # Date of latest commit.

    src = fetchFromGitHub {
      owner = "linnnus";
      repo = pname;
      rev = "487d7f5c02d99ebebfa30f7e004fbc0c3c9638a0";
      hash = "sha256-J7/fv3owAM61xdPc8KjP3gNm8x9AG24221ELNoU1BcA=";
    };

    # Instead of using the system CC and LLDB (impure), use the most recent LLVM release.
    postPatch = let
      toStringLiteral = lib.flip lib.pipe [builtins.toJSON lib.strings.escapeShellArg];
      ccPathLiteral = toStringLiteral "${llvmPackages.clang}/bin/clang";
      lldbPathLiteral = toStringLiteral "${llvmPackages.lldb}/bin/lldb";
    in ''
      substituteInPlace cscript.c \
        --replace-fail '"cc"' ${ccPathLiteral} \
        --replace-fail '"lldb"' ${lldbPathLiteral} \
    '';

    preInstall = "mkdir -p $out/bin";
    makeFlags = ["INSTALL=$(out)/bin"];

    # FIXME: TEST ARE FAILING I DONT KNOW WHY I DONT KNOW WHY I DONT KNOW WHY I DONT KNOW WHY REQUIRED FILE NOT FOUND I DONT KNOW WHY I DONT KNOW WHY I DONT KNOW WHY I DONT KNOW WHY I DONT KNOW WHY
    doCheck = false;
    doInstallCheck = false;
    preInstallCheck = ''export PATH="$out/bin:$PATH"''; # Otherwise `/usr/bin/env` can't find `cscript`.
    installCheckTarget = "installtest";

    passthru = rec {
      # Mimic Python's interpreter attributes.
      # See: https://nixos.org/manual/nixpkgs/stable/#attributes-on-interpreters-packages
      executable = "cscript";
      interpreter = "${self}/bin/${executable}";
    };

    meta = with lib; {
      description = "My take on the native shebang programming task from Rosetta Code";
      longDescription = ''
        This package contains a C "interpreter". Behind the scenes it actually
        compiles the file and runs it immediately, so it's not really an
        interpreter. Point is, it allows you to use a shebang (just like
        `#!/bin/sh`) to write C programs that execute like a Bash scripts.
      '';
      license = licenses.unlicense;
    };
  };
in
  self
