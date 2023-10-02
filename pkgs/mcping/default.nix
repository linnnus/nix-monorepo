{
  stdenv,
  fetchFromGitHub,
  lib,
}:
stdenv.mkDerivation rec {
  name = "mcping";
  version = "27-11-2019";

  src = fetchFromGitHub {
    owner = "theodik";
    repo = name;
    rev = "a4f8a711ed1b39f48aa655b58caccb26bb4d7ddb";
    hash = "sha256-BVZOjOqptEbva6kmI0oYNmodbLuL0nxKdWn/+EZG91U=";
  };

  buildPhase = ''
    cc -o mcping -Wall -Wextra mcping.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv mcping $out/bin
  '';

  meta = with lib; {
    description = "Query minecraft server via SLP (Server Listing Ping) to retrieve basic information";
    homepage = "https://github.com/theodik/mcping";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
