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
    let
      args = {
        flakeInputs = inputs;
        misc.metadata = nixpkgs.lib.importTOML ./metadata.toml;
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
	    ./use-cases/default.nix
          ];
        };
      };

      nixosConfigurations = {
        ahmed = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { _module.args = args; }
            home-manager.nixosModules.home-manager
            ./hosts/ahmed/configuration.nix
	    ./use-cases/default.nix
          ];
        };
      };
    };
}
