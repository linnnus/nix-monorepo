{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  imports = [./ignore.nix];

  programs.git = {
    enable = true;

    # Set privacy-respecting user information.
    userName = "Linnnus";
    userEmail = "linnnus@users.noreply.github.com";

    extraConfig.credential.helper = mkIf isDarwin ["osxkeychain"];
  };

  programs.git-credential-lastpass.enable = !isDarwin;

  home.shellAliases = {
    gs = "git status";
    gd = "git diff";
    gc = "git commit";
    ga = "git add";
    gan = "git add -N";
    gap = "git add --patch";
  };
}
