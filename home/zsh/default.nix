{ pkgs, config, lib, ... }:

{
  imports =
    [
      ./plugins.nix
    ];

  programs.zsh = {
    enable = true;

    defaultKeymap = "viins";

    # Feeble attempt at cleaning up home directory.
    # TODO: dotDir = (pathRelativeTo config.xdg.configHome config.home) + "/zsh";
    dotDir = ".config/zsh";
    history.path = config.xdg.cacheHome + "/zsh/history";

    initExtra = ''
      PROMPT='%F{41}->%f %B%(2L.LVL%L .)%b%F{red}%(?..E%? )%f%n@%U%m%u:%15<...<%~%<<%# '
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
