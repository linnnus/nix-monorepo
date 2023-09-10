pkgs:

{
  # duksebot = pkgs.callPackage ./duksebot { };

  still-awake = pkgs.callPackage ./still-awake { };

  # Use patched version from Karl.
  smu = pkgs.smu.overrideAttrs (old: {
    version = "2022-08-01";
    src = pkgs.fetchFromGitHub {
      owner = "karlb";
      repo = "smu";
      rev = "bd03c5944b7146d07a88b58a2dd0d264836e3322";
      hash = "sha256-Jx7lJ9UTHAOCgPxF2p7ZoZBZ476bLXN5dI0vspusmGo=";
    };
    #hardeningDisable = [ "fortify" ];
    env.NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + 
                             (pkgs.lib.strings.optionalString (pkgs.stdenv.cc.isGNU or false) " -Wno-maybe-uninitialized");
  });
}
