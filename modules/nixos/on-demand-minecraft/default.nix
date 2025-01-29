# This module defines an on-demand minecraft server service which turns off the
# server when it's not being used.
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types;

  # Custom type for Minecraft UUIDs which are used to uniquely identify players.
  minecraftUuid = lib.types.strMatching "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" // {description = "Minecraft UUID";};

  cfg = config.services.on-demand-minecraft;
in {
  options.services.on-demand-minecraft = {
    enable = mkEnableOption "local minecraft server";

    eula = mkOption {
      description = ''
        Whether you agree to [Mojangs EULA](https://account.mojang.com/documents/minecraft_eula).
        This option must be set to `true` to run a Minecraft™️ server (??).
      '';
      type = types.bool;
      default = false;
    };

    frequency-check-players = mkOption {
      description = ''
        How often to check the number of players using the server. If
        no players are using the server, it is shut down.

        This should be a valid value for systemd's `onCalendar`
        property.
      '';
      type = types.nonEmptyStr;
      default = "*-*-* *:*:0/20";
    };

    minimum-server-lifetime = mkOption {
      description = ''
        Minimum required time to pass from the server is started
        before it is allowed to be killed. This should ensure the
        server has time to start up before it is killed.

        The option is specified as a number of seconds.
      '';
      type = types.ints.positive;
      default = 300;
    };

    internal-port = mkOption {
      description = ''
        The internal port which the minecraft server will listen to.
        This port does not need to be exposed to the network.
      '';
      type = types.port;
      default = cfg.external-port + 1;
    };

    external-port = mkOption {
      description = ''
        The external port of the socket which is forwarded to the
        Minecraft server. This is the one users will connect to. You
        will need to add it to `networking.firewall.allowedTCPPorts`
        to open it in the firewall.

        You may also have to set up port forwarding if you want to
        play with friends who are not on the same LAN.
      '';
      type = types.port;
      default = 25565;
    };

    openFirewall = mkOption {
      description = ''
        Open holes in the firewall so clients on LAN can connect. You must
        set up port forwarding if you want to play over WAN.
      '';
      type = types.bool;
      default = true;
    };

    package = mkOption {
      description = "What Minecraft server to run.";
      default = pkgs.minecraft-server;
      type = types.package;
    };

    server-properties = mkOption {
      description = ''
        Minecraft server properties for the server.properties file. See
        <https://minecraft.gamepedia.com/Server.properties#Java_Edition_3>
        for documentation on these values. Note that some options like
        `server-port` will be forced on because they are required for the
        server to work.
      '';
      type = with types; attrsOf (oneOf [bool int str]);
      default = {};
      example = lib.literalExpression ''
        {
          difficulty = 3;
          gamemode = 1;
          motd = "My NixOS server!";
        }
      '';
    };

    whitelist = mkOption {
      description = ''
        Whitelisted players. This is a mapping from Minecraft usernames to
        UUIDs. You can use <https://mcuuid.net/> to get a Minecraft UUID for a
        username.

        Note, this option only has an effect when the whitelist is enabled via
        `services.on-demand-minecraft.server-properties` by setting `white-list
        = true`.
      '';
      type = with types; attrsOf minecraftUuid;
      example = lib.literalExpression ''
        {
          username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
          username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
        };
      '';
      default = {};
    };

    ops = mkOption {
      description = ''
        List of players with operator status.

        See <https://minecraft.wiki/w/Ops.json> for a description of how ops work.
      '';
      type = with types; let
        opsEntry = submodule {
          options = {
            username = mkOption {
              description = "The player's username";
              type = nonEmptyStr;
            };

            uuid = mkOption {
              description = ''
                The UUID associated with the player.

                You can use <https://mcuuid.net/> to get a Minecraft UUID for a username.
              '';
              type = minecraftUuid;
            };

            level = mkOption {
              description = ''
                The permission level that this user should be given. There are 5 possible levels:

                - Level 0: Everyone
                - Level 1: Moderator
                - Level 2: Gamemaster
                - Level 3: Administrator
                - Level 4: Owner

                See <https://minecraft.wiki/w/Permission_level> for an explanation of user permission levels.
              '';
              type = ints.between 0 4;
            };

            bypasses-player-limit = mkOption {
              description = "If true, the operator can join the server even if the player limit has been reached.";
              type = bool;
              default = false;
            };
          };
        };
      in
        listOf opsEntry;
      default = [];
    };

    jvm-options = mkOption {
      description = "JVM options for the Minecraft server. List of command line arguments.";
      type = with types; listOf str;
      default = ["-Xmx2048M" "-Xms2048M"];
    };

    data-dir = mkOption {
      description = ''
        Where to store game files.

        Note that you may have to clear this directory when changing
        `services.on-demand-minecraft.package`, as the servers may be confused
        about files they don't understand.
      '';
      type = types.path;
      default = "/var/lib/minecraft";
    };
  };

  config = mkIf cfg.enable {
    # TODO: We should contain all of this in a cgroup (a systemd slice?), which can be limited.

    # Create a user to run the server under.
    users.users.minecrafter = {
      description = "On-demand minecraft server service user";
      home = cfg.data-dir;
      createHome = true;
      group = "minecrafter";
      isSystemUser = true;
    };
    users.groups.minecrafter = {};

    # Create an internal socket and hook it up to minecraft-server process as
    # stdin. That way we can send commands to it.
    systemd.sockets.minecraft-server = {
      bindsTo = ["minecraft-server.service"];
      socketConfig = {
        ListenFIFO = "/run/minecraft-server.stdin";
        SocketMode = "0660";
        SocketUser = "minecrafter";
        SocketGroup = "minecrafter";
        RemoveOnStop = true;
        FlushPending = true;
      };
    };

    # Create a service which runs the server.
    systemd.services.minecraft-server = let
      server-properties =
        cfg.server-properties
        // {
          server-port = cfg.internal-port;
        };
      cfg-to-str = v:
        if builtins.isBool v
        then
          (
            if v
            then "true"
            else "false"
          )
        else toString v;
      server-properties-file = pkgs.writeText "server.properties" (''
          # server.properties managed by NixOS configuration.
        ''
        + lib.concatStringsSep "\n" (lib.mapAttrsToList
          (n: v: "${n}=${cfg-to-str v}")
          server-properties));

      # We don't allow eula=false anyways
      eula-file = builtins.toFile "eula.txt" ''
        # eula.txt managed by NixOS Configuration
        eula=true
      '';

      # We always generate a (possibly empty) whitelist file. The server just
      # won't use it, when the corresponding server property is disabled.
      whitelist-file =
        pkgs.writeText "whitelist.json"
        (builtins.toJSON
          (lib.mapAttrsToList (n: v: {
              name = n;
              uuid = v;
            })
            cfg.whitelist));

      # Takes a mapping of old attribute name -> new attribute name and applies
      # it to the given attribute set.
      renameAttrs = mappings: attrset: lib.attrsets.mapAttrs' (name: value: lib.attrsets.nameValuePair (mappings.${name} or name) value) attrset;

      ops-file =
        pkgs.writeText "ops.json"
        (builtins.toJSON (
          map (renameAttrs {
            "bypasses-player-limit" = "bypassesPlayerlimit";
            "username" = "name";
          })
          cfg.ops
        ));

      start-server = pkgs.writeShellScript "minecraft-server-start.sh" ''
        # Switch to runtime directory.
        ${pkgs.busybox}/bin/mkdir -p "${cfg.data-dir}"
        ${pkgs.busybox}/bin/chown minecrafter:minecrafter "${cfg.data-dir}"
        cd "${cfg.data-dir}"

        # Set up/update environment for server
        ln -sf ${eula-file} eula.txt
        ln -sf ${whitelist-file} whitelist.json
        ln -sf ${ops-file} ops.json
        cp -f ${server-properties-file} server.properties
        chmod u+w server.properties # Must be writable because server regenerates it.

        exec ${cfg.package}/bin/minecraft-server "$@"
      '';

      stop-server = pkgs.writeShellScript "minecraft-server-stop.sh" ''
        # Send the 'stop' command to the server. It listens for commands on stdin.
        echo stop > ${config.systemd.sockets.minecraft-server.socketConfig.ListenFIFO}
        # Wait for the PID of the minecraft server to disappear before
        # returning, so systemd doesn't attempt to SIGKILL it.
        while kill -0 "$1" 2> /dev/null; do
          sleep 1s
        done
      '';
    in {
      requires = ["minecraft-server.socket"];
      after = ["networking.target" "minecraft-server.socket"];
      wantedBy = []; # TEMP: Does this do anything?

      serviceConfig = {
        ExecStart = "${start-server} ${lib.escapeShellArgs cfg.jvm-options}";
        ExecStop = "${stop-server} $MAINPID";
        Restart = "always";

        User = "minecrafter";
        Group = "minecrafter";

        StandardInput = "socket";
        StandardOutput = "journal";
        StandardError = "journal";

        # Hardening
        CapabilityBoundingSet = [""];
        DeviceAllow = [""];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };

    # This socket listens for connections on the public port and
    # triggers `minecraft-listen.service` when a connection is made.
    systemd.sockets.minecraft-listen = {
      enable = true;
      wantedBy = ["sockets.target"];
      requires = ["network.target"];
      listenStreams = [(toString cfg.external-port)];
    };

    # This service is triggered by a TCP connection on the public
    # port. It starts minecraft-hook.service if it is not running
    # already and waits for it to return (using `after`). Then it proxifies the TCP
    # connection to the real (internal) Minecraft port.
    systemd.services.minecraft-listen = {
      enable = true;
      requires = ["minecraft-hook.service" "minecraft-listen.socket"];
      after = ["minecraft-hook.service" "minecraft-listen.socket"];
      serviceConfig.ExecStart = ''
        ${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString cfg.internal-port}
      '';
    };

    # This starts Minecraft if required and waits for it to be
    # available over TCP to unlock the `minecraft-listen.service`
    # proxy.
    systemd.services.minecraft-hook = {
      enable = true;
      # Add tools used by scripts to path.
      serviceConfig = let
        # Start the Minecraft server and the timer regularly
        # checking whether it should stop.
        start-mc = pkgs.writeShellScript "start-mc.sh" ''
          echo "Starting server and stop-timer..."
          ${pkgs.systemd}/bin/systemctl start minecraft-server.service \
            minecraft-stop.timer
        '';
        # Wait for the internal port to be accessible for max.
        # 60 seconds before complaining.
        wait-tcp = pkgs.writeShellScript "wait-tcp.sh" ''
          echo "Waiting for server to start listening on port ${toString cfg.internal-port}..."
          for i in `seq 60`; do
            if ${pkgs.netcat.nc}/bin/nc -z 127.0.0.1 ${toString cfg.internal-port} >/dev/null; then
              echo "Yay! ${toString cfg.internal-port} is now available. minecraft-hook is finished."
              exit 0
            fi
            sleep 1
          done
          echo "${toString cfg.internal-port} did not become available in time."
          exit 1
        '';
      in {
        # First we start the server, then we wait for it to become available.
        ExecStart = "${start-mc}";
        ExecStartPost = "${wait-tcp}";
      };
    };

    # This timer runs the service of the same name, that checks if
    # the server needs to be stopped.
    systemd.timers.minecraft-stop = {
      enable = true;
      timerConfig = {
        OnCalendar = cfg.frequency-check-players;
      };
    };

    systemd.services.minecraft-stop = let
      # Script that returns true (exit code 0) if the server can be shut
      # down. It uses mcping to get the player list. It does not continue if
      # the server was started less than `minimum-server-lifetime` seconds
      # ago.
      #
      # NOTE: `pkgs.mcping` is declared my personal monorepo. Hopefully
      # everything just works out through the magic of flakes, but if you are
      # getting errors like "missing attribute 'mcping'" that's probably why.
      no-player-connected = pkgs.writeShellScript "no-player-connected.sh" ''
        servicestartsec="$(date -d "$(systemctl show --property=ActiveEnterTimestamp minecraft-server.service | cut -d= -f2)" +%s)"
        serviceelapsedsec="$(( $(date +%s) - servicestartsec))"

        if [ $serviceelapsedsec -lt ${toString cfg.minimum-server-lifetime} ]; then
          echo "Server is too young to be stopped (minimum lifetime is ${toString cfg.minimum-server-lifetime}s, current is ''${serviceelapsedsec}s)"
          exit 1
        fi

        PLAYERS="$(${pkgs.mcping}/bin/mcping 127.0.0.1 ${toString cfg.internal-port} | ${pkgs.jq}/bin/jq .players.online)"
        echo "There are $PLAYERS active players"
        if [ $PLAYERS -eq 0 ]; then
          exit 0
        else
          exit 1
        fi
      '';
    in {
      enable = true;
      serviceConfig.Type = "oneshot";
      script = ''
        if ${no-player-connected}; then
          echo "Stopping minecraft server..."
          ${pkgs.systemd}/bin/systemctl stop minecraft-server.service \
            minecraft-hook.service \
            minecraft-stop.timer
        fi
      '';
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [cfg.external-port];
      allowedTCPPorts = [cfg.external-port];
    };

    assertions = [
      {
        assertion = cfg.eula;
        message = "You must agree to Mojangs EULA to run minecraft-server. Read https://account.mojang.com/documents/minecraft_eula and set `services.minecraft-server.eula` to `true` if you agree.";
      }
      {
        assertion = cfg.whitelist != {} -> cfg.server-properties."white-list" or false;
        message = "If you set a `services.on-demand-minecraft.whitelist`, you must set `services.on-demand-minecraft.server-properties.\"white-list\" = true`";
      }
    ];
  };
}
