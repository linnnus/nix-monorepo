# This module sets up an NGINX on this host.
#
# Different services' will register themselves with NGINX via
# `services.nginx.virtualHosts`. They may also want to order themselves before
# NGINX `systemd.services.*.{before,wantedBy}`.
{config, ...}: {
  # Virtual hosts.
  services.nginx.enable = true;

  # Configure ACME. This is used by various HTTP services through the NGINX virtual hosts.
  security.acme = {
    acceptTerms = true;
    defaults.email = "linusvejlo+${config.networking.hostName}-acme@gmail.com";
  };

  # Allow HTTP connections.
  networking.firewall.allowedTCPPorts = [80 443];

  services.fail2ban = {
    enable = true;

    jails = {
      "nginx-http-auth".settings = {
        enabled = true;
        port = "http,https";
        filter = "nginx-http-auth";
        logpath = "%(nginx_error_log)s";
      };

      "nginx-botsearch".settings = {
        enabled = true;
        port = "http,https";
        filter = "nginx-botsearch";
        logpath = "%(nginx_access_log)s";
      };

      "nginx-forbidden".settings = {
        enabled = true;
        port = "http,https";
        filter = "nginx-forbidden";
        logpath = "%(nginx_error_log)s";
      };

      "nginx-sslerror".settings = {
        enabled = true;
        port = "http,https";
        filter = "nginx-bad-request";
        logpath = "%(nginx_error_log)s";
      };
    };
  };
}
