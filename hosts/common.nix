# Shared configuraion regardless of hosts.

{ pkgs, options, self, ... }:

{
  # Enable de facto stable features.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use overlays from this repo for building system configuration as well as
  # system-wide.
  #
  # See: https://nixos.wiki/wiki/Overlays#Using_nixpkgs.overlays_from_configuration.nix_as_.3Cnixpkgs-overlays.3E_in_your_NIX_PATH
  nixpkgs.overlays = (import ../pkgs/overlays.nix);
  nix.nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=${self}/pkgs/overlays.nix" ];

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
    moreutils
  ];

  # Aliases that are burned into my muscle memory.
  environment.shellAliases = {
    "mv" = "mv -i";
    "rm" = "rm -i";
    "cp" = "cp -i";
    "ls" = "ls -A --color=auto";
    "grep" = "grep --color=auto";
    "file" = "file --no-dereference";
    "tree" = "tree --dirsfirst";
  };
}
