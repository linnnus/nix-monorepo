# This module defines an on-demand minecraft server service which turns off the
# server when it's not being used.
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.services.forsvarsarper;
in {
  options.services.forsvarsarper.enable = mkEnableOption "daily scan for tests";

  config = mkIf cfg.enable {
    # Create a user to run the server under.
    users.users.forsvarsarper = {
      description = "Runs daily scan for tests";
      group = "forsvarsarper";
      isSystemUser = true;
      home = "/srv/forsvarsarper";
      createHome = true;
    };
    users.groups.forsvarsarper = {};

    age.secrets.forsvarsarper-env = {
      file = ../../../secrets/forsvarsarper.env.age;
      owner = config.users.users.forsvarsarper.name;
      group = config.users.users.forsvarsarper.group;
      mode = "0440";
    };

    # Create a service which simply runs script. This will be invoked by our timer.
    systemd.services.forsvarsarper = {
      serviceConfig = {
        # We only want to run this once every time the timer triggers it.
        Type = "oneshot";
        # Run as the user we created above.
        User = "forsvarsarper";
        Group = "forsvarsarper";
        WorkingDirectory = config.users.users.forsvarsarper.home;
      };
      script =
        let
          python3' = pkgs.python3.withPackages (ps: [ps.requests]);
        in
        ''
          # Load the secret environment variables.
          export $(grep -v '^#' ${config.age.secrets.forsvarsarper-env.path} | xargs)
          # Kick off.
          exec ${python3'}/bin/python3 ${./script.py}
        '';
    };

    # Create a timer to activate our oneshot service.
    systemd.timers.forsvarsarper = {
      wantedBy = ["timers.target"];
      partOf = ["forsvarsarper.service"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      timerConfig = {
        OnCalendar = "*-*-* 8:00:00";
        Unit = "forsvarsarper.service";
      };
    };
  };
}
