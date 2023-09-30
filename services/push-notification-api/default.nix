# Temporary definition for push-notification-api service. This will be moved
# into the flake once it's finished.

{ pkgs, lib, config, flakeInputs, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.my.services.push-notification-api;
in
{
  options.my.services.push-notification-api = {
    enable = mkEnableOption "Push notification API";

    package = mkOption {
      description = "What package to use.";
      default = flakeInputs.push-notification-api.packages.${pkgs.system}.default;
      type = types.package;
    };

    host = mkOption {
      description = "Host(name) to passed to server";
      type = types.nonEmptyStr;
      default = "0.0.0.0";
    };

    port = mkOption {
      description = "Port to listen for requests on";
      type = types.port;
      default = 8000;
    };

    openFirewall = mkEnableOption "Poke holes in the firewall to permit LAN connections.";
  };

  config = mkIf cfg.enable {
    # Create a user to run the server under.
    users.users.push-notification-api = {
      description = "Runs daily dukse reminder";
      group = "push-notification-api";
      isSystemUser = true;
      home = "/srv/push-notification-api";
      createHome = true;
    };
    users.groups.push-notification-api = { };

    # Create a service which runs the server.
    systemd.services.push-notification-api = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "netowrk-online.target" ];
      wants = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = config.users.users.push-notification-api.name;
        Group = config.users.users.push-notification-api.group;
        WorkingDirectory = config.users.users.push-notification-api.home;
        ExecStart = ''
         "${cfg.package}"/bin/push-notification-api --port ${toString cfg.port} --host "${cfg.host}"
        '';
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
