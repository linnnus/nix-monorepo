{ pkgs, lib, config, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf optional;

  domain = "linus.onl";

  cfg = config.my.modules."${domain}";
in
{
  options.my.modules."${domain}" = {
    enable = mkEnableOption "${domain} static site";

    useACME = mkEnableOption "built-in HTTPS stuff";

    openFirewall = mkOption {
      description = ''
        Open holes in the firewall so clients on LAN can connect. You must
        set up port forwarding if you want to play over WAN.
      '';
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Create a user to run the build script under.
    users.users."${domain}-builder" = {
      description = "builds ${domain}";
      group = "${domain}-builder";
      isSystemUser = true;
    };
    users.groups."${domain}-builder" = { };

    # Create the output directory.
    system.activationScripts."${domain}-create-www" = lib.stringAfter [ "var" ] ''
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
      startAt = "*-*-* *:00/5:00";

      path = with pkgs; [ git tcl smu rsync ];
      script = ''
        set -ex
        cd $(mktemp -d -t linus.onl-source.XXXXXXXXXXXX)
        # TODO: Only do minimal possible cloning
        git clone https://github.com/linnnus/${domain} .
        tclsh build.tcl
        rsync --archive --delete _build/ /var/www/${domain}
      '';

      # TODO: Harden service

      # We must generate some files for NGINX to serve, so this should be run
      # before NGINX.
      before = [ "nginx.service" ];
      wantedBy = [ "nginx.service" ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 80 ] ++ (optional cfg.useACME 443);
    };

    # Serve the generated page using NGINX.
    services.nginx = {
      enable = true;

      virtualHosts."${domain}" = {
        enableACME = cfg.useACME;
        root = "/var/www/${domain}";
      };
    };
  };
}
