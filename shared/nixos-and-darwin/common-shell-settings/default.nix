# This module sets options to ensure a consistent Baseline Shell Experince™
# across the entire fleet. This includes e.g. common utilities and aliases.
#
# NOTE: This lives under `shared/nixos-and-darwin`. The configuration in here
# should be compatible with both nixos and nix-darwin!!
{pkgs, ...}: {
  # Set ZSH as the shell.
  # https://nixos.wiki/wiki/Command_Shell#Changing_default_shelltrue
  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];

  # Very basic system administration tools.
  environment.systemPackages = with pkgs; [
    curl
    jq
    moreutils
    neovim
    tree
  ];

  # Aliases that are burned into my muscle memory.
  environment.shellAliases = {
    "mv" = "mv -i";
    "rm" = "rm -i";
    "cp" = "cp -i";
    "ls" = "ls -F -G -A --color=auto";
    "grep" = "grep --color=auto";
    "file" = "file --no-dereference";
    "tree" = "tree --dirsfirst --gitignore";

    # See: https://github.com/NixOS/nix/issues/5858
    "nix" = "nix --print-build-logs";

    ".." = "cd ../";
    "..." = "cd ../../";
    "...." = "cd ../../../";
    "....." = "cd ../../../../";
    "......" = "cd ../../../../../";
    "......." = "cd ../../../../../../";
    "........" = "cd ../../../../../../../";
    "........." = "cd ../../../../../../../../";
    ".........." = "cd ../../../../../../../../../";
  };
}
