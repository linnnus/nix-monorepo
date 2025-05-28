{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption mkOption;
  inherit (lib.types) nullOr attrs;
  inherit (lib.generators) toPlist;

  cfg = config.programs.iterm2;
in {
  options.programs.iterm2 = {
    enable = mkEnableOption "Iterm2 terminal emulator";

    package = mkPackageOption pkgs "iterm2" {};

    shellIntegration = {
      enableZshIntegration = mkEnableOption "Zsh integraion";
      enableBashIntegration = mkEnableOption "Bash integration";
      enableFishIntegration = mkEnableOption "Fish integration";
    };

    config = mkOption {
      # FIXME: This breaks iTerm2 too much. Create a patch for iTerm2 that
      # loads `$XDG_CONFIG_HOME/iterm2/iterm2.plist` in addition to the usual
      # `~/Library/Preferences/com.googlecode.iterm2.plist`.
      description = ''
        Application preferences. If these are specified, they are serialized to
        PLIST and stored in `~/Library/Preferences/com.googlecode.iterm2.plist`.

        Note that iTerm2 acts weirdly in some aspects when it cannot write to
        aforementioned prefrences file (such as is the case when using
        home-manager to manage the file). For example, changing settings using
        the GUI are not persistant between sessions. Furtherore, some iTerm2
        also appears to be storing other miscellaneous non-configration state
        in the folder (e.g. `NoSyncTipOfTheDayEligibilityBeganTime`).

        For these reasons, the default is non-declarative management. When this
        option is set to `null` (the default), no file is generated.
      '';
      type = nullOr attrs;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    # TODO: Use the same overwriting approach as for qBittorrent.
    home.file = mkIf (cfg.config != null) {
      "/Library/Preferences/com.googlecode.iterm2.plist".text = toPlist {} cfg.config;
    };

    programs.zsh.initContent = mkIf cfg.shellIntegration.enableZshIntegration ''
      # Added by home-manager because programs.iterm2.enableZshIntegration == true.
      source "${cfg.package}"/Applications/iTerm2.app/Contents/Resources/iterm2_shell_integration.zsh
    '';
    programs.bash.initExtra = mkIf cfg.shellIntegration.enableBashIntegration ''
      # Added by home-manager because programs.iterm2.enableBashIntegration == true.
      source "${cfg.package}"/Applications/iTerm2.app/Contents/Resources/iterm2_shell_integration.bash
    '';
    programs.fish.interactiveShellInit = mkIf cfg.shellIntegration.enableFishIntegration ''
      # Added by home-manager because programs.iterm2.enableFishIntegration == true.
      source "${cfg.package}"/Applications/iTerm2.app/Contents/Resources/iterm2_shell_integration.fish
    '';
  };
}
