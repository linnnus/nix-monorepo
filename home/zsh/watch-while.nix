# This module configures some ZSH aliases such that 'watch-while' is invoked
{
  pkgs,
  lib,
  ...
}: let
  # Program to invoke for long-running commands.
  pkg = pkgs.watch-while;

  # Prorams to wrap with watch-while.
  toWrap = ["nixos-rebuild" "darwin-rebuild" "nmap"];
in {
  # Alias long-running commands to their prefixed versions. These aliases are
  # only loaded for interactive use, so they won't mess with scripts.
  programs.zsh.shellAliases =
    lib.genAttrs toWrap (p: "${pkg}/bin/${pkg.pname} ${p}")
    # Enable alias expansion after sudo with this trick.
    // {
      "sudo" = "sudo ";
      "ww" = "watch-while ";
    };

  # Also add the program to the environment for manual invocation.
  home.packages = [pkg];
}
