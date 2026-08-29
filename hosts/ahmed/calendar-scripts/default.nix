{
  lib,
  pkgs,
  metadata,
  ...
}: let
  buildUser = "calendar-chump";

  # Where we'll store generated calendars.
  wwwDir = "/var/www/calendars";
in {
  # Create a user to run the build script(s) under.
  users.users.${buildUser} = {
    description = "Builds some calendar files";
    group = buildUser;
    isSystemUser = true;
  };
  users.groups.${buildUser} = {};

  # Create the output directory.
  system.activationScripts."calendar-scripts-create-www" = lib.stringAfter ["var"] ''
    mkdir -p ${lib.escapeShellArg wwwDir}
    chown ${buildUser} ${lib.escapeShellArg wwwDir}
    chgrp ${buildUser} ${lib.escapeShellArg wwwDir}
    chmod 0755 ${lib.escapeShellArg wwwDir}
  '';

  # Set up job to generate file
  systemd.services."calendar-scripts" = {
    description = "generates calendars n shit";

    serviceConfig = {
      Type = "oneshot";
      User = buildUser;
      Group = buildUser;
    };

    path = with pkgs; [
      (pkgs.python3.withPackages (ps: with ps; [ical requests]))
    ];
    script = ''
      cd ${lib.escapeShellArg wwwDir}

      export RESULT_PATH=./brightspace.ics
      export CALENDAR_URL='https://brightspace.au.dk/d2l/le/calendar/feed/user/feed.ics?token=afheb4nch2x8poqz1c094'
      python3 ${./fix_brightspace.py}
    '';

    # Network must be online for us to check.
    after = ["network-online.target" "nss-lookup.target"];
    wants = ["network-online.target" "nss-lookup.target"];
  };

  # Configure NGINX to serve the file under personal domain
  services.nginx.virtualHosts.${metadata.domains.personal} = {
    locations."/calendars/" = {
      alias = wwwDir + "/";
      extraConfig = ''
        autoindex on;
      '';
    };
  };
}
