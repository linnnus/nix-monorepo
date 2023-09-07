{ pkgs, lib, config, ... }:

let
  inherit (lib.strings) concatStringsSep;
  inherit (lib.attrsets) catAttrs;

  plugins = 
    [
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
        name = "zsh-cwd-history";
        src = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "zsh-cwd-history";
          version = "73afed8";

          src = pkgs.fetchFromGitHub {
            owner = "ericfreese";
            repo = pname;
            rev = version;
            hash = "sha256-xW11wPFDuFU80AzgAgLwkvK7Qv58fo3i3kSasE3p0zs=";
          };

          fixupPhase = ''
            substituteInPlace ${pname}.zsh \
              --replace md5 ${pkgs.hashdeep}/bin/md5deep

            mkdir -p $out
            mv * $out
          '';

          # This is kind of a weird, useless derivation, so we have to
          # manually avoid doing lots of the usual stuff.
          dontInstall = true;
        };
        config = ''
          # Where to but history files
          export ZSH_CWD_HISTORY_DIR=${config.xdg.dataHome}/zsh-cwd-history
          mkdir -p "$ZSH_CWD_HISTORY_DIR"

          # Toggle between global/local history
          bindkey '^G' cwd-history-toggle
        '';
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
    ];
in
{
  programs.zsh = {
    plugins = map (p: removeAttrs p ["config"]) plugins;

    initExtra = concatStringsSep "\n" (catAttrs "config" plugins);
  };
}
