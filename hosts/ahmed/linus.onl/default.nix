{
  pkgs,
  lib,
  ...
}: let
  # The domain to serve. Also kinda embedded in the name of the module??
  domain = "linus.onl";

  # Enable HTTPS stuff.
  useACME = true;
in {
  config = {
    # Create a user to run the build script under.
    users.users."${domain}-builder" = {
      description = "builds ${domain}";
      group = "${domain}-builder";
      isSystemUser = true;
    };
    users.groups."${domain}-builder" = {};

    # Create the output directory.
    system.activationScripts."${domain}-create-www" = lib.stringAfter ["var"] ''
      mkdir -p /var/www/${domain}
      chown ${domain}-builder /var/www/${domain}
      chgrp ${domain}-builder /var/www/${domain}
      chmod 0755 /var/www/${domain}
    '';

    # Create a systemd service which rebuild the site regularly.
    #
    # This can't be done using Nix because the site relies on the git build and
    # there are some inherent difficulties with including .git/ in the
    # inputSource for derivations.
    #
    # See: https://github.com/NixOS/nix/issues/6900
    # See: https://github.com/NixOS/nixpkgs/issues/8567
    #
    # TODO: Integrate rebuilding with GitHub webhooks to rebuild on push.
    systemd.services."${domain}-source" = {
      description = "generate https://${domain} source";

      serviceConfig = {
        Type = "oneshot";
        User = "${domain}-builder";
        Group = "${domain}-builder";
      };

      path = with pkgs; [
        git
        rsync
        coreutils-full
        tcl-8_5
        gnumake
      ];
      environment.TCLLIBPATH = "$TCLLIBPATH ${pkgs.tcl-cmark}/lib/tclcmark1.0";
      script = ''
        set -ex
        tmpdir="$(mktemp -d -t linus.onl-source.XXXXXXXXXXXX)"
        cd "$tmpdir"
        trap 'rm -rf $tmpdir' EXIT
        # TODO: Only do minimal possible cloning
        git clone https://github.com/linnnus/${domain} .
        make _build
        rsync --archive --delete _build/ /var/www/${domain}
      '';

      # TODO: Harden service

      # Network must be online for us to check.
      after = ["network-online.target"];
      requires = ["network-online.target"];

      # We must generate some files for NGINX to serve, so this should be run
      # before NGINX.
      before = ["nginx.service"];
      wantedBy = ["nginx.service"];
    };

    # Start the source fetching shit only after network acess has been achieved.
    systemd.timers."${domain}-source" = {
      after = ["network-online.target"];
      requires = ["network-online.target"];
      wantedBy = ["timers.target"];
      timerConfig.OnCalendar = ["*-*-* *:00/5:00"];
    };

    # Register domain name with ddns.
    services.cloudflare-dyndns.domains = [domain];

    # Register virtual host.
    services.nginx = {
      virtualHosts."${domain}" = {
        # NOTE: 'forceSSL' will cause an infite loop, if the cloudflare proxy does NOT connect over HTTPS.
        enableACME = useACME;
        forceSSL = useACME;
        root = "/var/www/${domain}";
      };
    };
  };
}
