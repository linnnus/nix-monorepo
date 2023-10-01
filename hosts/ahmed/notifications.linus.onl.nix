{ pkgs, lib, config, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf optional;

  domain = "notifications.linus.onl";

  # TODO: Make option internal-port.
  internal-port = 13082;

  cfg = config.modules."notifications.linus.onl";
in
{
  options.modules."notifications.linus.onl" = {
    enable = mkEnableOption "notifications.linus.onl static site";

    useACME = mkEnableOption "built-in HTTPS stuff";
  };

  config = mkIf cfg.enable {
    my.services.push-notification-api = {
      enable = true;
      # host = "notifications.linus.onl";
      host = "0.0.0.0";
      port = internal-port;
      openFirewall = false; # We're using NGINX reverse proxy.
    };

    # Register domain name.
    services.cloudflare-dyndns.domains = [ "notifications.linus.onl" ];

    # Serve the generated page using NGINX.
    services.nginx.virtualHosts."notifications.linus.onl" = {
      enableACME = cfg.useACME;
      forceSSL = cfg.useACME;
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:${toString internal-port}";
      };
    };
  };
}
