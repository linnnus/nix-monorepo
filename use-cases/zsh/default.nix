{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;

    defaultKeymap = "viins";

    # Feeble attempt at cleaning up home directory.
    # TODO: dotDir = (pathRelativeTo config.xdg.configHome config.home) + "/zsh";
    dotDir = ".config/zsh";
    history.path = config.xdg.cacheHome + "/zsh/history";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}