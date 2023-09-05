# This configuration is centered around use cases, rather than profiles. Since
# all of the machines I manage are single-user machines, there's no point in
# creating multiple users.
#
# While the users don't differ, the use cases definitely do. I use some
# machines for homework and gaming, while others are used for web-browsing and
# development. Each use case is a subdirectory with (home-manager)
# configuration options.
#
# Note that e.g. "running a DNS server" is not a use case. That's specified in
# the respective host's `configuration.nix`.

{ config, lib, flakeInputs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.use-cases;
in
{
  options.my.use-cases = {
    development.enable = mkEnableOption "development use case";
    sysadmin.enable = mkEnableOption "sysadmin use case";
  };

  config = {
    home-manager.users.linus = {
      imports =
        (lib.optional cfg.development.enable ./development) ++
        (lib.optional cfg.sysadmin.enable ./sysadmin);
	# TODO: Graphical linux config (remember assertion).

       xdg.enable = true;
    };

    # Pass
    home-manager.extraSpecialArgs = {
      super = config;
      inherit flakeInputs;
    };

    home-manager.useGlobalPkgs = true;
  };
}
