{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    push-notification-api = {
      url = "github:linnnus/push-notification-api";
      # url = "path:/home/linus/push-notification-api";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comma = {
      url = "github:linnnus/comma-zsh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    webhook-listener = {
      url = "github:linnnus/webhook-listener";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    agenix,
    push-notification-api,
    webhook-listener,
    ...
  } @ inputs: let
    args = {
      flakeInputs = inputs;
      flakeOutputs = self.outputs;
      metadata = nixpkgs.lib.importTOML ./metadata.toml;
    };

    # This is a function that generates an attribute by calling a function
    # you pass to it, with each system as an argument. `systems` lists all
    # supported systems.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    darwinConfigurations = {
      muhammed = nix-darwin.lib.darwinSystem {
        inherit inputs;
        system = "aarch64-darwin";
        modules =
          [
            {_module.args = args;}
            home-manager.darwinModules.home-manager
            agenix.darwinModules.default
            ./hosts/muhammed/configuration.nix
          ]
          ++ builtins.attrValues (import ./modules/darwin);
      };
    };

    nixosConfigurations = {
      ahmed = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          [
            {_module.args = args;}
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            push-notification-api.nixosModules.default
            webhook-listener.nixosModules.default
            ./hosts/ahmed/configuration.nix
          ]
          ++ builtins.attrValues (import ./modules/nixos);
      };
    };

    # Formatter to be run when `nix fmt` is executed.
    formatter =
      forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = builtins.attrValues self.overlays;
      };
    in
      import ./pkgs pkgs);

    overlays = import ./overlays;

    # We export the generally applicable modules.
    darwinModules = import ./modules/darwin;
    homeModules = import ./modules/home-manager;
    nixosModules = import ./modules/nixos;
  };
}
