# This module implements a really simple and shitty WSGI app which streams
# journald logs to the client. I don't expect it to hang around for long, so
# it's just quickly hacked together.
#
# FIXME: There's still the issue with broken connections. Perhaps heartbeat would fix.
{
  pkgs,
  config,
  ...
}: let
  socket-path = "/run/minecraft-log-server.sock";

  python = pkgs.python3.withPackages (ps:
    with ps; [
      gevent
      gunicorn
    ]);
in {
  users.users.minecraft-log-server = {
    description = "Runs minecraft-log-server";
    group = "minecraft-log-server";
    isSystemUser = true;
  };
  users.groups.minecraft-log-server = {};

  systemd.sockets.minecraft-log-server = {
    description = "Socket where the service of the same name answers HTTP requests.";

    socketConfig = {
      ListenStream = socket-path;

      # TODO: wtf apple maps
      SocketUser = "nginx";
      SocketGroup = "nginx";
      SocketMode = "600";
    };

    wantedBy = ["sockets.target"];
  };

  # See: https://docs.gunicorn.org/en/23.0.0/deploy.html
  systemd.services.minecraft-log-server = {
    description = "Minecraft log server";

    serviceConfig = {
      # Using a non-sync worker class is super important because we have such long-running connections.
      ExecStart = "${python}/bin/gunicorn --worker-class=gevent --chdir ${./.} minecraft_log_server:app";

      ExecReload = "kill -s HUP $MAINPID";
      KillMode = "mixed";

      User = config.users.users.minecraft-log-server.uid;
      Group = config.users.users.minecraft-log-server.group;

      # gunicorn can let systemd know when it is ready
      Type = "notify";
      NotifyAccess = "main";

      # Harden
      ProtectSystem = "strict";
      PrivateTmp = true;
    };

    requires = ["minecraft-log-server.socket"]; # Refuse to start without.
    after = ["network.target"];
  };

  services.nginx = {
    virtualHosts."minecraft.linus.onl" = {
      # Let's be safe and pass-word protect it just in case the logs contain some sensitive data.
      basicAuthFile = ./.htpasswd;

      # First try resolving files statically, before falling back to the CGI server.
      locations."/" = {
        alias = "${./public}/";
        index = "index.html";
        tryFiles = "$uri $uri/ @minecraft_log_server";
      };

      locations."@minecraft_log_server" = {
        recommendedProxySettings = true;

        # In addition to the important stuff set indirectly via `recommendedProxySettings`
        # (especially `proxy_http_version`), we need these options for SSE.
        extraConfig = ''
          # Disable buffering. This is crucial for SSE to ensure that
          # messages are sent immediately without waiting for a buffer to
          # fill.
          proxy_buffering off;

          # Disable caching to ensure that all messages are sent and received
          # in real-time without being cached by the proxy.
          proxy_cache off;

          # Set a long timeout for reading from the proxy to prevent the
          # connection from timing out. You may need to adjust this value
          # based on your specific requirements.
          proxy_read_timeout 86400;
        '';

        proxyPass = "http://unix:${socket-path}:$request_uri";
      };
    };
  };

  services.cloudflare-dyndns.domains = ["minecraft.linus.onl"];
}
