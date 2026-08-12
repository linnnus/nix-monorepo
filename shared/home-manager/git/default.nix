{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) optional;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  imports = [
    ./aliases.nix
  ];

  programs.git = {
    enable = true;

    settings = {
      # Set privacy-respecting user information.
      user.name = "Linnnus";
      user.email = "linnnus@users.noreply.github.com";

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
        helper = ["cache"];
      };
    };
  };

  home.packages = with pkgs; [
    # Add the GitHub CLI for authentication.
    gh
  ];

  xdg.configFile."git/ignore".source = ./ignore;
}
