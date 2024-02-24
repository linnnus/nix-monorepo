# This module defines systemd unit which runs a script that sends Discrord
# messages. I use it to notify my classmates about who's on cleaning duty. You
# are probably not interested in this.
{
  config,
  pkgs,
  ...
}: let
  # What script to run.
  package = pkgs.duksebot;
in {
  config = {
    # Create a user to run the server under.
    users.users.duksebot = {
      description = "Runs daily dukse reminder";
      group = "duksebot";
      isSystemUser = true;
      home = "/srv/duksebot";
      createHome = true;
    };
    users.groups.duksebot = {};

    age.secrets.duksebot-env = {
      file = ../../../secrets/duksebot.env.age;
      owner = config.users.users.duksebot.name;
      group = config.users.users.duksebot.group;
      mode = "0440";
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
        export $(grep -v '^#' ${config.age.secrets.duksebot-env.path} | xargs)
        # Kick off.
        exec "${package}"/bin/duksebot
      '';
    };

    # Create a timer to activate our oneshot service.
    systemd.timers.duksebot = {
      wantedBy = ["timers.target"];
      partOf = ["duksebot.service"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      timerConfig = {
        OnCalendar = "*-*-* 7:00:00";
        Unit = "duksebot.service";
      };
    };
  };
}
