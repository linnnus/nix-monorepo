{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
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
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dark-notify = {
      url = "github:linnnus/dark-notify";
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
    dark-notify,
    ...
  } @ inputs: let
    args = {
      metadata = nixpkgs.lib.importTOML ./metadata.toml;
    };
    specialArgs = {
      flakeInputs = inputs;
      flakeOutputs = self.outputs;
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
        inherit inputs specialArgs;
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
	inherit specialArgs;
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
      ali = nixpkgs.lib.nixosSystem {
	inherit specialArgs;
        system = "x86_64-linux";
        modules =
          [
            {_module.args = args;}
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            ./hosts/ali/configuration.nix
          ]
          ++ builtins.attrValues (import ./modules/nixos);
      };
    };

    # Formatter to be run when `nix fmt` is executed.
    formatter =
      forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # We have to use the `legacyPackages` output because it contains the
    # package set `vimPackages` and `packages` must be an attribute set of
    # derivations. Otherwise `flake check` complains (see: nix-community/fenix#60).
    legacyPackages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in
      import ./overlays/additions.nix pkgs pkgs);

    overlays = {
      additions = import ./overlays/additions.nix;
      modifications = import ./overlays/modifications.nix;
    };

    # We export the generally applicable modules.
    darwinModules = import ./modules/darwin;
    homeModules = import ./modules/home-manager;
    nixosModules = import ./modules/nixos;
  };
}
