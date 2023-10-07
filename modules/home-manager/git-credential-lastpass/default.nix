{pkgs, config, lib, ...}: let inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.modules) mkIf;
  cfg = config.programs.git-credential-lastpass;
in {
  options.programs.git-credential-lastpass = {
    enable = mkEnableOption "Lastpass credential helper";

    package = mkPackageOption pkgs "lastpass-cli" {};
  };

  config = mkIf cfg.enable {
    programs.git.extraConfig.credential.helper = [ "${cfg.package}/bin/git-credential-lastpass" ];
  };
}
