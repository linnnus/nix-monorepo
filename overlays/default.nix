# This module lists the different overlays. These are exported in `flake.nix`.

{
  # This overlay adds all of our custom packages.
  additions = final: _prev: import ../pkgs final;

  # This overlay does typical overlay stuff such as adding patches, bumping versions, etc.
  modifications = final: prev: {
    # Use patched version from Karl.
    smu = prev.smu.overrideAttrs (old: {
      version = "2022-08-01";
      src = final.fetchFromGitHub {
        owner = "karlb";
        repo = "smu";
        rev = "bd03c5944b7146d07a88b58a2dd0d264836e3322";
        hash = "sha256-Jx7lJ9UTHAOCgPxF2p7ZoZBZ476bLXN5dI0vspusmGo=";
      };
      env.NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") +
                               (final.lib.strings.optionalString (final.stdenv.cc.isGNU or false) " -Wno-maybe-uninitialized");
    });
  };
}
