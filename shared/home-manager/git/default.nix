{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) optional;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  imports = [
    ./ignore.nix
    ./aliases.nix
  ];

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

      # It seems like a de facto standard to have a file with this name in the
      # project root containing all the commits that should be ignored when
      # running `git blame`.
      blame.ignoreRevsFile = ".git-blame-ignore-revs";

      credential = {
        "https://github.com/" = {
          username = "linnnus";
          helper = "${pkgs.gh}/bin/gh auth git-credential";
        };
        helper = (optional isDarwin "osxkeychain") ++ ["cache"];
      };
    };
  };

  home.packages = with pkgs; [
    # Add the GitHub CLI for authentication.
    gh
  ];
}
