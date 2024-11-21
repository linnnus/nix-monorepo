{
  stdenv,
  lib,
  fetchFromGitHub,
  llvmPackages,
}: let
  self = stdenv.mkDerivation rec {
    pname = "cscript";
    version = "16-11-2024"; # Date of latest commit.

    src = fetchFromGitHub {
      owner = "linnnus";
      repo = pname;
      rev = "855f35a4e6d5046000a1d9ff7b887ccd7c4a8c91";
      hash = "sha256-d722f3K3QXnPqDVNVGBK+mj6Bl1VNShmJ4WICj0p64s=";
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
