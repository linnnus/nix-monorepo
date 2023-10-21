{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) optional;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  imports = [./ignore.nix ./aliases.nix];

  programs.git = {
    enable = true;

    # Set privacy-respecting user information.
    userName = "Linnnus";
    userEmail = "linnnus@users.noreply.github.com";

    extraConfig.credential = {
      "https://github.com/".username = "linnnus";

      helper = (optional isDarwin "osxkeychain") ++ ["cache"];
    };
  };
}
