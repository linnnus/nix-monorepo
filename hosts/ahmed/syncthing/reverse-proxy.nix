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
    password = "$y$j9T$mLlnLvW2XHNH3xlL0Vlnr1$Aa1tc2/c0qAKkp/5yt0F7dBD8pSjzqwgAIL4bZ/sAa9";
  };

  linus.local-dns.subdomains = ["syncthing"];
}
