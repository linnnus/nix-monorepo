# This module defines the HelloHTML web server. It extends the NGINX config
# with a virtual server that proxies the local HelloHTML service.

{ ... }: let
  useACME = true;
in {
  config = {
    # Start service listening on socket /tmp/hellohtml.sock
    services.hellohtml = {
      enable = true;
    };

    # Register domain name.
    services.cloudflare-dyndns.domains = ["hellohtml.linus.onl"];

    # Use NGINX as reverse proxy.
    services.nginx.virtualHosts."hellohtml.linus.onl" = {
      enableACME = useACME;
      forceSSL = useACME;
      locations."/" = rec {
        proxyPass = "http://localhost:8538";
        # Disable settings that might mess with the text/event-stream response of the /listen/:id endpoint.
        # NOTE: These settings work in tanden with Cloudflare Proxy settings descibed here:
        #       https://blog.devops.dev/implementing-server-sent-events-with-fastapi-nginx-and-cloudflare-10ede1dffc18
        extraConfig = ''
          location /listen/ {
            # Have to duplicate this here, as this directive is not inherited.
            # See: https://blog.martinfjordvald.com/understanding-the-nginx-configuration-inheritance-model/
            # See: https://serverfault.com/q/1082562
            proxy_pass ${proxyPass};
            # Disable connection header.
            # See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Connection
            # See: https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#no-keepalives
            proxy_set_header Connection \'\';
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
          }
        '';
      };
    };
  };
}
