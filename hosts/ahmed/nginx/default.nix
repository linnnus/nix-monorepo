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
}
