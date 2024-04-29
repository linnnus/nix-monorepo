# This module defines a service which runs a headless qBittorrent instance
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  defaultUser = "qbittorrent";
  defaultGroup = "qbittorrent";

  cfg = config.services.qbittorrent;
in {
  options.services.qbittorrent = {
    enable = lib.mkEnableOption "headless qBittorrent instance";

    port = lib.mkOption {
      description = "The port on which to serve the WebUI.";
      type = lib.types.port;
      default = 8080;
    };

    openFirewall = lib.mkOption {
      description = ''
        Open holes in the firewall so clients on LAN can connect to the web
        interface. You must set up port forwarding if you want it accessable
        from the wider internet.
      '';
      type = lib.types.bool;
      default = false;
    };

    profile = lib.mkOption {
      description = ''
        The directory where qBittorrent should store it's data files. Note that
        these are for qBittorrent itself, not the files it downloads. Those are
        controlled through the configuration option `XXX`.
      '';
      type = lib.types.path;
      default = "/var/lib/qBittorrent";
    };

    user = lib.mkOption {
      description = ''
        The user to run the qBittorrent service as.

        The user is not automatically created if it is changed from the default value.
      '';
      type = lib.types.str;
      default = defaultUser;
    };

    group = lib.mkOption {
      description = ''
        The group to run the qBittorrent service as.

        The group is not automatically created if it is changed from the default value.
      '';
      type = lib.types.str;
      default = defaultGroup;
    };

    package = lib.mkOption {
      description = "qBittorrent package to use";
      type = lib.types.package;
      default = pkgs.qbittorrent-nox;
    };

    settings = lib.mkOption rec {
      description = ''
        An attribute set whose values overrides the ones specified in
        `qBittorrent.conf`.

        These values are applied on top of the existing configuration when the
        service starts. This is a necessary compromise between determinism and
        usability, as qBittorrent also saves all kinds of gunk in the
        configuration file.
      '';
      type = lib.types.attrs;
      default = {
        LegalNotice = {
          Accepted = false;
        };
      };
      apply = lib.recursiveUpdate default;
      example = {
        LegalNotice = {
          Accepted = true;
        };
        Preferences = {
          "Connection\\PortRangeMin" = 20082;
          "Downloads\\SavePath" = "/mnt";
          "WebUI\\UseUPnP" = false;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Create the user/group if required.
    users.users = lib.mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        description = "Runs ${options.services.qbittorrent.enable.description}";
        group = cfg.group;
        isSystemUser = true;
      };
    };
    users.groups = lib.mkIf (cfg.group == defaultGroup) {
      ${defaultGroup} = {};
    };

    # Set up a service to run qBittorrent
    # See: https://github.com/qbittorrent/qBittorrent/blob/615b76f78c8ab92ad57bed42fc4266950c9f0251/dist/unix/systemd/qbittorrent-nox%40.service.in
    systemd.services.qbittorrent = {
      enable = true;

      unitConfig = {
        Wants = ["network-online.target"];
        After = ["local-fs.target" "network-online.target" "nss-lookup.target"];
      };

      serviceConfig = {
        Type = "simple";

        User = cfg.user;
        Group = cfg.group;
        PrivateTmp = false;

        ExecStartPre = let
          format = pkgs.formats.ini {};
          settingsFile = format.generate "qBittorrent.conf" cfg.settings;
          configPath = "${cfg.profile}/qBittorrent/config/qBittorrent.conf";

          start-pre-script = pkgs.writeShellScript "qbittorrent-start-pre" ''
             set -ue

             # Create data directory if it doesn't exist
             if ! test -d ${cfg.profile}; then
               echo "Creating initial qBittorrent data directory in: ${cfg.profile}"
               install -d -m 0755 -o ${cfg.user} -g ${cfg.group} ${cfg.profile}/qBittorrent/config/
             fi

            # Force-apply configuration.
            ${pkgs.crudini}/bin/crudini --ini-options=nospace --merge ${configPath} <${settingsFile}
          '';
        in
          # Requires full permissions to create data directory, hence the "!".
          "!${start-pre-script}";
        ExecStart = pkgs.writeShellScript "qbittorrent-start" ''
          exec ${cfg.package}/bin/qbittorrent-nox --webui-port=${toString cfg.port} --profile=${cfg.profile}
        '';
        TimeoutStopSec = 1800;

        # Set as low-priority
        IOSchedulingClass = "idle";
        IOSchedulingPriority = "7";
      };

      wantedBy = ["multi-user.target"];
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };
  };
}
