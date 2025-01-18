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
        function _prompt_git_branch_name() {
          local branch="$(git symbolic-ref HEAD 2>/dev/null | awk 'BEGIN{FS="/"} {print $NF}')"
          if ! [ -z "$branch" ]; then
            echo ' ('$branch')'
          fi
        }
        # loong looooong prooooompt – Nagāi Sakeru Gumi
        PROMPT='%B%(2L.LVL%L .)%b%F{red}%(?..E%? )%f%F{93}%n%f@%F{35}%m%f%F{blue}$(_prompt_git_branch_name)%f# '
      fi
      RPROMPT='%F{green}%$((COLUMNS/4))<...<%~%<<%f'

      mkcd () {
        mkdir "$1" && cd "$1"
      }
    '';
  };
}
