# Shared configuraion regardless of hosts.

{ pkgs, ... }:

{
  # Enable de facto stable features.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set ZSH as the shell.
  # https://nixos.wiki/wiki/Command_Shell#Changing_default_shelltrue
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];
  users.users.linus.shell = pkgs.zsh;

  # Very basic system administration tools.
  environment.systemPackages = with pkgs; [
    tree
    jc
    jq
    vim
    comma
    curl
  ];

  # Aliases that are burned into my muscle memory.
  environment.shellAliases = {
    "mv" = "mv -i";
    "rm" = "rm -i";
    "cp" = "cp -i";
    "ls" = "ls -A --color=auto";
    "grep" = "grep --color=auto";
    "file" = "file --no-dereference";
  };
}
