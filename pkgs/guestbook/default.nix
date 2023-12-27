{pkgs}:
pkgs.stdenv.mkDerivation {
  pname = "guestbook";
  version = "0.0.0";

  src = ./.;

  buildInputs = with pkgs; [sqlite];
  nativeBuildInputs = with pkgs; [pkg-config];

  buildPhase = "./build.sh";
  installPhase = "mkdir -p $out/bin; mv guestbook $out/bin";

  # This must be set for environment.shells to recognize this as a shell package.
  passthru.shellPath = "/bin/guestbook";
}
