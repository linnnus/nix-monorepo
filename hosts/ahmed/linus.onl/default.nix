{
  pkgs,
  lib,
  config,
  ...
}: let
  # The domain to serve. Also kinda embedded in the name of the module??
  domain = "linus.onl";

  # Enable HTTPS stuff.
  useACME = true;

  # When run, this command causes a rebuild of the website source. See the service defintion for how the site is rebuilt.
  startServiceCommand = "/run/current-system/sw/bin/systemctl start ${domain}-source.service";

  # Name of the "production" branch where the live content goes.
  mainBranch = "main";
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

    # Create a systemd service which rebuild the site.
    #
    # This can't be done using Nix because the site relies on the git build and
    # there are some inherent difficulties with including .git/ in the
    # inputSource for derivations.
    #
    # See: https://github.com/NixOS/nix/issues/6900
    # See: https://github.com/NixOS/nixpkgs/issues/8567
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
        until host github.com >/dev/null 2>&1; do sleep 1; done
        tmpdir="$(mktemp -d -t linus.onl-source.XXXXXXXXXXXX)"
        cd "$tmpdir"
        trap 'rm -rf $tmpdir' EXIT
        git clone --branch=${mainBranch} --filter=blob:none https://github.com/linnnus/${domain} .
        make _build
        rsync --archive --delete _build/ /var/www/${domain}
      '';

      # TODO: Harden service

      # Network must be online for us to check.
      # FIXME: This configuration still attempts to run without network/DNS/something, which fails and breaks automatic NixOS updrades.
      # https://wiki.archlinux.org/title/Systemd#Running_services_after_the_network_is_up
      # https://systemd.io/NETWORK_ONLINE/#discussion
      after = ["network-online.target" "nss-lookup.target"];
      wants = ["network-online.target" "nss-lookup.target"];

      # We must generate some files for NGINX to serve, so this should be run
      # before NGINX.
      before = ["nginx.service"];
      wantedBy = ["nginx.service"];
    };

    # This service will listen for webhook events from GitHub's API. Whenever
    # it receives a "push" event, it will start the rebuild service.
    services.webhook-listener = {
      enable = true;

      commands = [
        {
          event = "push";
          command = toString (pkgs.writeShellScript "handle-push-event.sh" ''
            ${pkgs.jq}/bin/jq --exit-status '.ref == "refs/heads/${mainBranch}"' >/dev/null
            case $? in
              0)
                ${config.security.wrapperDir}/sudo ${startServiceCommand}
                ;;
              1)
                echo "Not the target ref. Exciting"
                exit 0
                ;;
              *)
                echo "Got jq error. Exiting." >&2
                exit 1
                ;;
            esac
          '');
        }
      ];

      max-idle-time = "10min";

      secret-path = config.age.secrets."linus.onl-github-secret".path;
    };

    # We have shared a secret with GitHub, which we use to verify requests. Here we decrypt that secret.
    age.secrets."linus.onl-github-secret" = {
      file = ../../../secrets/linus.onl-github-secret.txt.age;

      owner = config.services.webhook-listener.user;
      group = config.services.webhook-listener.group;
    };

    # Commands run by `webhook-listener` are run as an inpriviledged user for
    # security reasons. We have to specifically give that user permission to start this one service.
    security.sudo.extraRules = [
      {
        users = [config.services.webhook-listener.user];
        commands = [
          {
            command = startServiceCommand;
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    # Register domain name with ddns.
    services.cloudflare-dyndns.domains = [domain];

    # Register virtual host.
    services.nginx = {
      virtualHosts."${domain}" = {
        # NOTE: 'forceSSL' will cause an infite loop, if the cloudflare proxy does NOT connect over HTTPS.
        enableACME = useACME;
        forceSSL = useACME;
        root = "/var/www/${domain}";

        # I have pointed the GitHub webhook requests at <https://linus.onl/webhook>.
        # These should be forwarded to `/` on the listening socket server.
        locations."= /webhook" = {
          recommendedProxySettings = true;
          proxyPass = "http://unix:${config.services.webhook-listener.socket-path}:/";
        };
      };
    };
  };
}
