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
      env.NIX_CFLAGS_COMPILE =
        (old.env.NIX_CFLAGS_COMPILE or "")
        + (final.lib.strings.optionalString (final.stdenv.cc.isGNU or false) " -Wno-maybe-uninitialized");
    });

    # Use newest version.
    noweb = prev.noweb.overrideAttrs (old: rec {
      version = "2_13rc3";
      src = final.fetchFromGitHub {
        owner = "nrnrnr";
        repo = "noweb";
        rev = "v${builtins.replaceStrings ["."] ["_"] version}";
        sha256 = "COcWyrYkheRaSr2gqreRRsz9SYRTX2PSl7km+g98ljs=";
      };
      # Have to discard old patches as the no longer apply cleanly.
      patches = [./noweb-no-unnecessary-cflags.patch];
    });
  };
}
