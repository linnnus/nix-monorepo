{config, ...}: {
  imports = [
    ./plugins.nix
    ./editing.nix
  ];

  programs.zsh = {
    enable = true;

    # Feeble attempt at cleaning up home directory.
    # TODO: dotDir = (pathRelativeTo config.xdg.configHome config.home) + "/zsh";
    dotDir = ".config/zsh";
    history.path = config.xdg.cacheHome + "/zsh/history";

    initExtra = ''
      set -o PROMPTSUBST
      if [ -v NVIM -o -v VIM ]; then
        # smol prompt
        PROMPT='%# '
      else
        # loong looooong prooooompt – Nagāi Sakeru Gumi
        PROMPT='%B%(2L.LVL%L .)%b%F{red}%(?..E%? )%f%F{93}%n%f@%F{35}%m%f%# '
      fi
      RPROMPT='%F{green}%$((COLUMNS/4))<...<%~%<<%f'

      mkcd () {
        mkdir "$1" && cd "$1"
      }
    '';
  };
}
