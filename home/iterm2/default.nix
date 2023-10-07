# This file configures iterm2. Note that the actual definition of iTerm2 for
# home-manager is in `modules/home-manager/iterm2`. *That* file declares
# `options.programs.iterm2.enable`.
{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isDarwin;
in {
  config = mkIf isDarwin {
    programs.iterm2 = {
      enable = true;
      config = {
        SoundForEsc = false;
      };
    };
  };
}
