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

    shellAliases = {
      "mv" = "mv -i";
      "rm" = "rm -i";
      "cp" = "cp -i";
      "ls" = "ls -A --color=auto";
      "grep" = "grep --color=auto";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
