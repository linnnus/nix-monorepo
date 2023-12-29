{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-23.11";
    };
    nixpkgs-unstable = {
      url = "nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
    hellohtml = {
      url = "github:linnnus/hellohtml";
      # url = "path:/home/linus/hellohtml";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    agenix,
    push-notification-api,
    hellohtml,
    ...
  } @ inputs: let
    args = {
      flakeInputs = inputs;
      flakeOutputs = self.outputs;
      metadata = nixpkgs.lib.importTOML ./metadata.toml;
    };

    darwinModules =
      builtins.attrValues (import ./modules/darwin).general
      ++ builtins.attrValues (import ./modules/darwin).personal;
    nixosModules =
      builtins.attrValues (import ./modules/nixos).general
      ++ builtins.attrValues (import ./modules/nixos).personal;

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
            ./hosts/muhammed/configuration.nix
            ./hosts/common.nix
            ./home
          ]
          ++ darwinModules;
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
            hellohtml.nixosModules.default
            ./hosts/ahmed/configuration.nix
            ./hosts/common.nix
            ./home
          ]
          ++ nixosModules;
      };
    };

    # Formatter to be run when `nix fmt` is executed.
    formatter =
      forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    overlays = import ./overlays;

    # We export the generally applicable modules.
    darwinModules = (import ./modules/darwin).geneal;
    nixosModules = (import ./modules/nixos).general;
    homeModules = import ./modules/home-manager;
  };
}
