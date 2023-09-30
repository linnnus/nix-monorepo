# This module defines an on-demand minecraft server service which turns off the
# server when it's not being used.

{ config, lib, pkgs, modulesPath, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types;

  cfg = config.my.services.duksebot;
in
{
  options.my.services.duksebot = {
    enable = mkEnableOption "duksebot daily reminder";

    package = mkOption {
      description = "What package to use";
      default = pkgs.duksebot;
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    # Create a user to run the server under.
    users.users.duksebot = {
      description = "Runs daily dukse reminder";
      group = "duksebot";
      isSystemUser = true;
    };
    users.groups.duksebot = { };

    my.secrets.duksebot = {
      source = ./secrets.env;
      dest = "/run/keys/duksebot.env";
      owner = "duksebot";
      group = "duksebot";
    };

    # Create a service which simply runs script. This will be invoked by our timer.
    systemd.services.duksebot = {
      serviceConfig = {
        # We only want to run this once every time the timer triggers it.
        Type = "oneshot";
        # Run as the user we created above.
        User = "duksebot";
        Group = "duksebot";
        WorkingDirectory = config.users.users.duksebot.home;
      };
      script = ''
        # Load the secret environment variables.
        export $(grep -v '^#' /run/keys/duksebot.env | xargs)
        # Kick off.
        exec "${cfg.package}"/bin/duksebot
      '';
    };

    # Create a timer to activate our oneshot service.
    systemd.timers.duksebot = {
      wantedBy = [ "timers.target" ];
      partOf = [ "duksebot.service" ];
      # Here's where we depend on the deployment secret which
      # we registered under my.secrets.duksebot!
      after = [ "duksebot-key.service" "network-online.target" ];
      wants = [ "duksebot-key.service" "network-online.target" ];
      timerConfig = {
        # OnCalendar = "*-*-* 7:00:00";
        OnCalendar = "*:0/1";
        Unit = "duksebot.service";
      };
    };
  };
}
