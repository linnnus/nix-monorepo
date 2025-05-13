{config, ...}: {
  # Use NGINX as a reverse proxy.
  # See: https://docs.syncthing.net/users/reverseproxy.html
  services.nginx = {
    virtualHosts."syncthing.${config.linus.local-dns.domain}" = {
      locations."/" = {
        proxyPass = "http://${config.services.syncthing.guiAddress}";
        recommendedProxySettings = true;
      };
    };
  };

  # By default Syncthing checks that the Host header says "localhost" which
  # will not be the case when using a reverse proxy.
  #
  # See: https://docs.syncthing.net/users/faq.html#why-do-i-get-host-check-error-in-the-gui-api
  services.syncthing.settings.gui = {
    insecureSkipHostcheck = true;

    user = "linus";
    password = "$2a$12$1OkFkWMKoWZbG2.aVcqHquo3lrP8ZC.hlMDQkdcIEX1uwAYjxEWUy";
  };

  linus.local-dns.subdomains = ["syncthing"];
}
