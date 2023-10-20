{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  imports = [./ignore.nix ./aliases.nix];

  programs.git = {
    enable = true;

    # Set privacy-respecting user information.
    userName = "Linnnus";
    userEmail = "linnnus@users.noreply.github.com";

    extraConfig.credential.helper = mkIf isDarwin ["osxkeychain"];
  };

  programs.git-credential-lastpass.enable = !isDarwin;
}
