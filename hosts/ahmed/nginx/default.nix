# This module sets up an NGINX on this host.
#
# Different services' will register themselves with NGINX via
# `services.nginx.virtualHosts`. They may also want to order themselves before
# NGINX `systemd.services.*.{before,wantedBy}`.
{config, ...}: {
  # Virtual hosts.
  services.nginx.enable = true;

  # I've had some issues with a random virtual host (depending on evaluation
  # order, I guess) being promoted to Default Server(TM). It results in weird
  # behavior when the requested host isn't recognized: like sending the wrong
  # certificate and stuff. Very annoying.
  #
  # This explicit default host should hopefully solve that by just dropping
  # any requests as soon as possible.
  services.nginx.virtualHosts = {
    "default-virtual-host" = {
      serverName = "_";
      default = true;

      # For HTTP, the non-standard return code 444 indicates to NGINX that it
      # should drop the request immediately without sending a response to the
      # client [0]. This is the recommended way to reject unrecognized server
      # names [1].
      #
      # [0]: https://nginx.org/en/docs/http/ngx_http_rewrite_module.html#return
      # [1]: https://nginx.org/en/docs/http/request_processing.html#how_to_prevent_undefined_server_names
      locations."/".return = "444";

      # For HTTPS, we don't want to use "return 444" as the directive is only
      # processed _after_ NGINX already has established an SSL connection which
      # means sending over a (nonsense) certificate. The `ssl_reject_handshake`
      # directive exists explicitly for this purpose [0].
      #
      # [0]: https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_reject_handshake
      rejectSSL = true; # Drop SSL connections before a certificate has been sent.
    };
  };

  # Configure ACME. This is used by various HTTP services through the NGINX virtual hosts.
  security.acme = {
    acceptTerms = true;
    # NOTE: The certificate in `local-dns/certficates.nix` uses a different email!
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
