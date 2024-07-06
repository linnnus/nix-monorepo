# Shared configuraion regardless of hosts.
{
  pkgs,
  options,
  flakeInputs,
  flakeOutputs,
  ...
}: {
  # Enable de facto stable features.
  nix.settings.experimental-features = ["nix-command" "flakes"];

  nixpkgs.overlays = [
    # Use local overlays.
    flakeOutputs.overlays.additions
    flakeOutputs.overlays.modifications

    # Add unstable nixpkgs.
    (final: prev: {unstable = flakeInputs.nixpkgs-unstable.legacyPackages.${pkgs.system};})
  ];

  # Use overlays from this repo for building system configuration as well as
  # system-wide.
  #
  # See: https://nixos.wiki/wiki/Overlays#Using_nixpkgs.overlays_from_configuration.nix_as_.3Cnixpkgs-overlays.3E_in_your_NIX_PATH
  nix.nixPath = options.nix.nixPath.default ++ ["nixpkgs-overlays=${flakeInputs.self}/overlays/compat.nix"];

  # Set ZSH as the shell.
  # https://nixos.wiki/wiki/Command_Shell#Changing_default_shelltrue
  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];
  users.users.linus.shell = pkgs.zsh;

  # Very basic system administration tools.
  environment.systemPackages = with pkgs; [
    tree
    gh
    vim
    flakeInputs.comma.packages.${system}.default
    nix-index
    curl
    moreutils
    flakeInputs.agenix.packages.${system}.default
    jq
  ];

  # Aliases that are burned into my muscle memory.
  environment.shellAliases = {
    "mv" = "mv -i";
    "rm" = "rm -i";
    "cp" = "cp -i";
    "ls" = "ls -F -G -A --color=auto";
    "grep" = "grep --color=auto";
    "file" = "file --no-dereference";
    "tree" = "tree --dirsfirst";

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
