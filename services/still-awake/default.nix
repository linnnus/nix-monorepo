{ pkgs, lib, config, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.my.services.still-awake;
in
{
  options.my.services.still-awake.enable = mkEnableOption "still-awake launchd job";

  config = mkIf cfg.enable {
    launchd.agents."still-awake" =
      let
        # https://macperformanceguide.com/blog/2022/20221125_2044-launch_daemon-launchctl-posix-spawn-permission-denied.html
        log-file = "/tmp/still-awake.log";
      in
      {
        enable = true;
        config = {
          ProgramArguments = [ "${pkgs.still-awake}/bin/still-awake" ];
          ProcessType = "Interactive";

          # WARNING: These times must match the ones specified in ${source}!
          StartCalendarInterval = [
            { Hour = 21; Minute = 30; }
            { Hour = 22; }
            { Hour = 22; Minute = 30; }
            { Hour = 23; }
            { Hour = 23; Minute = 30; }
            { Hour = 23; }
            { Hour = 23; Minute = 30; }
            { Hour = 00; }
            { Hour = 00; Minute = 30; }
            { Hour = 01; }
            { Hour = 01; Minute = 30; }
            { Hour = 02; }
            { Hour = 02; Minute = 30; }
            { Hour = 03; }
            { Hour = 03; Minute = 30; }
            { Hour = 04; }
            { Hour = 04; Minute = 30; }
            { Hour = 05; }
          ];

          StandardOutPath = log-file;
          StandardErrorPath = log-file;
        };
      };
  };
}
