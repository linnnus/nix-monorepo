{ config, lib, flakeInputs, ... }:

let
  inherit (lib) mkOption types optional elem;

  hasUseCase = c: elem c config.my.use-cases;
in
{
  options.my.use-cases = mkOption {
    description = "use-cases/modules to enable";
    type = types.listOf (types.enum ["gui" "development" "sysadmin"]);
  };

  config = {
    home-manager.users.linus = {
      imports = 
        (optional (hasUseCase "development") ./neovim) ++
        (optional (hasUseCase "development") && (hasUseCase "gui" && pkgs.stdenv.isDarwin) ./kitty) ++
        (optional (hasUseCase "development") && (hasUseCase "gui" && pkgs.stdenv.isLinux) ./st) ++
        (optional (hasUseCase "sysadmin") || (hasUseCase "development") ./zsh) ++
        (optional (hasUseCase "sysadmin") || (hasUseCase "development") ./cli-basics.nix);

      xdg.enable = true;
    };

    home.extraSpecialArgs = {
      super = config;
      inherit flakeInputs;
    };

    home.useGlobalPkgs = true;
  };
}
