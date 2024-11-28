{
  stdenv,
  lib,
  fetchFromGitHub,
  # TODO: I think the PR will become part of 24.11, at which point this becomes unnecessary.
  # TEMP: We unstable for NixOS/nixpkgs#309165 for LLDB to work on Darwin.
  unstable,
}: let
  self = stdenv.mkDerivation rec {
    pname = "cscript";
    version = "16-11-2024"; # Date of latest commit.

    src = fetchFromGitHub {
      owner = "linnnus";
      repo = pname;
      rev = "45c8dca682484a6a5873e38d917960ff1f7e971e";
      hash = "sha256-KhmHd8mQ387aSfXPAm7sJNFXlUKNyKPRITG1JUUjRE4=";
    };

    # Instead of using the system CC and LLDB (impure), use the most recent LLVM release.
    postPatch = let
      toStringLiteral = lib.flip lib.pipe [builtins.toJSON lib.strings.escapeShellArg];
      ccPathLiteral = toStringLiteral "${unstable.llvmPackages.clang}/bin/clang";
      lldbPathLiteral = toStringLiteral "${unstable.llvmPackages.lldb}/bin/lldb";
    in ''
      substituteInPlace cscript.c \
        --replace-fail '"cc"' ${ccPathLiteral} \
        --replace-fail '"lldb"' ${lldbPathLiteral} \
    '';

    preInstall = "mkdir -p $out/bin";
    makeFlags = ["INSTALL=$(out)/bin"];

    doCheck = true;
    doInstallCheck = true;
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
