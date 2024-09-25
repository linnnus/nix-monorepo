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

    extraConfig = {
      init.defaultBranch = "master";

      help.autoCorrect = "prompt";

      # Make sure we don't accidentally update submodules with changes that are only available locally.
      # See: https://git-scm.com/book/en/v2/Git-Tools-Submodules
      push.recurseSubmodules = "check";

      credential = {
        "https://github.com/" = {
          username = "linnnus";
          helper = "${pkgs.gh}/bin/gh auth git-credential";
        };
        helper = (optional isDarwin "osxkeychain") ++ ["cache"];
      };
    };
  };
}
