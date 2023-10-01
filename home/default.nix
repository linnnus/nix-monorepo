{
  flakeInputs,
  flakeOutputs,
  metadata,
  ...
}: {
  # Use the flake input pkgs so Home Manager configuration can share overlays
  # etc. with the rest of the configuration.
  home-manager.useGlobalPkgs = true;

  # Pass special arguments from flake.nix further down the chain. I really hate
  # this split module system.
  home-manager.extraSpecialArgs = {inherit flakeInputs flakeOutputs metadata;};

  # OKAY FUCK THIS SHIT. THERE IS ONE USER. IT IS ME. LINUS. I WILL ADD
  # MULTIUSER SUPPORT IF IT EVER BECOMES A REQUIREMENT.
  home-manager.users.linus = {
    imports = [
      ./neovim
      ./zsh
      ./git
      ./dev-utils
    ];

    xdg.enable = true;
  };
}
