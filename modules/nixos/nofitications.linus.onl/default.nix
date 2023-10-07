{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf optional;

  domain = "notifications.linus.onl";

  cfg = config.modules."notifications.linus.onl";
in {
  options.modules."notifications.linus.onl" = {
    enable = mkEnableOption "notifications.linus.onl static site";

    useACME = mkEnableOption "built-in HTTPS stuff";
  };

  config = mkIf cfg.enable {
    services.push-notification-api = {
      enable = true;
    };

    # Register domain name.
    services.cloudflare-dyndns.domains = ["notifications.linus.onl"];

    # Use NGINX as reverse proxy.
    services.nginx.virtualHosts."notifications.linus.onl" = {
      enableACME = cfg.useACME;
      forceSSL = cfg.useACME;
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://unix:/run/push-notification-api.sock";
      };
    };
  };
}
