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
    home.packages = with pkgs; [imgcat];

    programs.iterm2 = {
      enable = true;
      # config = {
      #   # Use the minimal tab style.
      #   # See: https://github.com/gnachman/iTerm2/blob/bd40fba0611fa94684dadf2478625f2a93eb6e47/sources/iTermPreferences.h#L29
      #   TabStyleWithAutomaticOption = 5;
      # };

      shellIntegration.enableZshIntegration = true;
    };
  };
}
