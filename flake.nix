{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-22.11";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }@inputs:
    {
      darwinConfigurations = {
        muhammed = nix-darwin.lib.darwinSystem {
          inherit inputs;
          system = "aarch64-darwin";
          modules = [
	    { _module.args = { flakeInputs = inputs; }; }
            ./hosts/muhammed/configuration.nix
            home-manager.darwinModules.home-manager
	    ./use-cases/default.nix
          ];
        };
      };

      nixosConfigurations = {
        ahmed = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { _module.args = { flakeInputs = inputs; }; }
            ./hosts/ahmed/configuration.nix
            home-manager.nixosModules.home-manager
	    ./use-cases/default.nix
          ];
        };
      };
    };
}
