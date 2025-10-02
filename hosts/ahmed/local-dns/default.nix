# This module sets up local DNS so that services on this host become visible to devices on LAN.
# The work is split in submodules, coordinated via the options set in this module:
#
# - certificates.nix: Get certs for HTTPS (surprisingly hard)
# - dns-resolver.nix: Make local domains visible to devices
#
# See the files for more info on how each part works.
{
  lib,
  metadata,
  ...
}: {
  imports = [
    ./certificates.nix
    ./dns-resolver.nix
    ./reverse-proxy.nix
  ];

  options = {
    linus.local-dns = {
      domain = lib.mkOption {
        description = ''
          A (sub)domain we have ownership over.

          To devices using our DNS cache (on port 53), it will look like this
          computer has the authority over that domain. It should not be used to
          server anything public, as that would then be overwritten.
        '';
        type = lib.types.nonEmptyStr;
      };

      # TODO: This assumes that all subdomains are located on this host. What about our NAS? Be more flexible.
      subdomains = lib.mkOption {
        description = ''
          List of subdomains that to {option}`domain` which are in use.
        '';
        type = with lib.types; listOf nonEmptyStr;
        default = [];
      };
    };
  };

  config = {
    linus.local-dns.domain = "rumpenettet.${metadata.domains.personal}";
  };
}
