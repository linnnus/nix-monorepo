# This file defines an overlay overlay does typical overlay stuff such as adding patches, bumping versions, etc.
final: prev: {
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

  # Use a slightly newer version of qBittorrent that doesn't include the password bug.
  #
  # See: https://old.reddit.com/r/qBittorrent/comments/1827zqn/locked_out_of_qbittorrent/kahat1u/?context=3
  # See: https://www.qbittorrent.org/news#mon-nov-27th-2023---qbittorrent-v4.6.2-release
  qbittorrent-nox = prev.qbittorrent-nox.overrideAttrs (old: rec {
    version = "4.6.2";
    src = final.fetchFromGitHub {
      owner = "qbittorrent";
      repo = "qBittorrent";
      rev = "release-${version}";
      hash = "sha256-+leX0T+yJUG6F7WbHa3nCexQZmd7RRfK8Uc+suMJ+vI=";
    };
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
    patches = (old.patches or []) ++ [./noweb-no-unnecessary-cflags.patch];
  });
}
