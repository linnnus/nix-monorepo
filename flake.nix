{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-23.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, agenix, ... }@inputs:
    let
      args = {
        inherit self;
        flakeInputs = inputs;
        metadata = nixpkgs.lib.importTOML ./metadata.toml;
      };
    in
    {
      darwinConfigurations = {
        muhammed = nix-darwin.lib.darwinSystem {
          inherit inputs;
          system = "aarch64-darwin";
          modules = [
	    { _module.args = args; }
            home-manager.darwinModules.home-manager
            ./hosts/muhammed/configuration.nix
            ./hosts/common.nix
            ./home
            # FIXME: Get the following to work without nix-darwin bithcing about unused NixOS options.
            # ./modules
            # ./services
          ];
        };
      };

      nixosConfigurations = {
        ahmed = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { _module.args = args; }
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            ./hosts/ahmed/configuration.nix
            ./hosts/common.nix
            ./home
	    ./modules
            ./services
          ];
        };
      };
    };
}
