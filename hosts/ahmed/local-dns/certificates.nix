# Getting HTTPS to work for local domains is pretty hard. The approach I've
# gone with is to request a wildcard domain for `*.rumpenettet.linus.onl`. We
# can do this because `linus.onl` is a public domain which we have control
# over.
#
# This module requests a certificate from letsencrypt using DNS-01
# verification. I have an API token which can modify DNS records for
# `linus.onl`. This is how Lego (i.e. `security.acme`) proves domain ownership
# when renewing the certificate.
#
# Any services running under `rumpenettet.local.onl` and use this certificate.
# For NGINX that happens via `useACMEHost` and one of the options that enable
# HTTPS.
{
  lib,
  config,
  ...
}: {
  security.acme = {
    certs.${config.linus.local-dns.domain} = {
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = config.age.secrets.cloudflare-acme-token.path;
      dnsPropagationCheck = true;
      domain = "*.${config.linus.local-dns.domain}";

      group = config.services.nginx.group;
      reloadServices = ["nginx"];
    };
  };

  # This file contains the variables that Lego needs to authenticate to
  # Cloudflare. This is how we prove ownership of the domain.
  #
  # See: https://go-acme.github.io/lego/dns/cloudflare/
  # See: https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
  age.secrets.cloudflare-acme-token.file = ../../../secrets/cloudflare-acme-token.env.age;

  # Use the certificate for each subdomain in NGINX. Luckily, we can be pretty
  # opinionated since this isn't reusable logic.
  #
  # NOTE: This assumes that each subdomain *has* an NGINX virtual host, which
  #       may not be the case in the future.
  services.nginx.virtualHosts = let
    virtualHostConfig = subdomain:
      lib.nameValuePair "${subdomain}.${config.linus.local-dns.domain}" {
        forceSSL = true;
        useACMEHost = config.linus.local-dns.domain; # Same as security.acme.certs.${...} above.
      };
  in
    builtins.listToAttrs (map virtualHostConfig config.linus.local-dns.subdomains);
}
