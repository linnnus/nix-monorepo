# This module manages behavioral plugins – plugins that alter how ZSH acts (e.g. autovenv, direnv).
{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib.strings) concatStringsSep;
  inherit (lib.attrsets) catAttrs;

  plugins = [
    {
      name = "autovenv";
      src = pkgs.fetchFromGitHub {
        owner = "linnnus";
        repo = "autovenv";
        rev = "d9f0cd7";
        hash = "sha256-GfJIybMYxE97xLSkrOSGsn+AREmnCyqe9n2aZwjw4w4=";
      };
    }
    {
      name = "zsh-vi-mode-cursor";
      src = pkgs.fetchFromGitHub {
        owner = "Buckmeister";
        repo = "zsh-vi-mode-cursor";
        rev = "fa7cc0973ee71636e906e25e782d0aea19545d60";
        hash = "sha256-j73M4bvAoHWt5Wwg47hM0p5Or74x/3btTOPnI22SqG8=";
      };
    }
    {
      name = "zsh-nix-shell";
      file = "nix-shell.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "chisui";
        repo = "zsh-nix-shell";
        rev = "v0.7.0";
        sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
      };
    }
  ];
in {
  programs.zsh = {
    plugins = map (p: removeAttrs p ["config"]) plugins;

    initExtra = concatStringsSep "\n" (catAttrs "config" plugins);
  };
}
