# This module adds some extra configuration useful when running behid a Cloudflare Proxy.
#
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.modules.cloudflare-proxy;
in {
  options.modules.cloudflare-proxy.enable = mkEnableOption "Cloudflare proxy IP extraction for NGINX";

  config = mkIf cfg.enable {
    # Teach NGINX how to extract the proxied IP from proxied requests.
    #
    # See: https://nixos.wiki/wiki/Nginx#Using_realIP_when_behind_CloudFlare_or_other_CDN
    services.nginx.commonHttpConfig = let
      realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
      fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
      cfipv4 = fileToList (pkgs.fetchurl {
        url = "https://www.cloudflare.com/ips-v4";
        sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
      });
      cfipv6 = fileToList (pkgs.fetchurl {
        url = "https://www.cloudflare.com/ips-v6";
        sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
      });
    in ''
      ${realIpsFromList cfipv4}
      ${realIpsFromList cfipv6}
      real_ip_header CF-Connecting-IP;
    '';

    # TODO: Only allow incomming HTTP{,S} requests from non-Cloudflare IPs.
  };
}
