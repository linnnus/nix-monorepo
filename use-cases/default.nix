{ config, pkgs, lib, flakeInputs, misc, ... }:

let
  inherit (lib) mkOption types optional elem;

  hasUseCase = c: elem c config.my.use-cases;
  development = hasUseCase "development";
  sysadmin = hasUseCase "sysadmin";
  gui = hasUseCase "gui";
in
{
  options.my.use-cases = mkOption {
    description = "use-cases/modules to enable";
    type = types.listOf (types.enum ["gui" "development" "sysadmin"]);
  };

  config = {
    home-manager.users.linus = {
      imports = (optional development ./neovim)
             ++ (optional development ./git)
            #++ (optional (development && gui && pkgs.stdenv.isDarwin) ./iterm2)
            #++ (optional (development && gui && pkgs.stdenv.isDarwin) ./st)
             ++ (optional (development || sysadmin) ./zsh)
             ++ (optional (development || sysadmin) ./cli-basics.nix);

      xdg.enable = true;
    };

    home-manager.extraSpecialArgs = {
      super = config;
      inherit flakeInputs misc;
    };

    home-manager.useGlobalPkgs = true;
  };
}
