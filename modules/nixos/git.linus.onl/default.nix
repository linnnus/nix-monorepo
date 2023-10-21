{
  lib,
  config,
  pkgs,
  options,
  metadata,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;

  git-shell = "${pkgs.gitMinimal}/bin/git-shell";

  cfg = config.modules."git.linus.onl";
in {
  options.modules."git.linus.onl" = {
    enable = mkEnableOption "git.linus.onl static site";

    useACME = mkEnableOption "built-in HTTPS stuff";

    location = mkOption {
      description = "Where repositories will be stored.";
      type = types.path;
      default = "/srv/git";
    };
  };

  config = mkIf cfg.enable {
    # Create a user which
    # See: https://git-scm.com/book/en/v2/Git-on-the-Server-Setting-Up-the-Server
    users.users.git = {
      description = "Git server user";
      isSystemUser = true;
      group = "git";

      # FIXME: Is serving the home-directory of a user (indirectly through CGit) a bad idea?
      home = cfg.location;
      createHome = false;

      # Restrict this user to Git-related activities.
      # See: https://git-scm.com/docs/git-shell
      shell = git-shell;

      # List of users who can ssh into this server and write to stuff. We add
      # some restrictions on what users can do on the server. This works in
      # tandem with the custom shell.
      openssh.authorizedKeys.keys =
        map (key: "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ${key}")
        [
          metadata.hosts.muhammed.sshPubKey
        ];
    };
    users.groups.git = {};

    environment.shells = [git-shell];

    # Create repo directory. It must be readable to NGINX.
    # See: https://git.zx2c4.com/cgit/about/faq#why-doesnt-cgit-findshow-my-repo
    system.activationScripts.create-cgit-scan-path = mkIf (cfg.location == options.modules."git.linus.onl".location.default) ''
      mkdir -p ${cfg.location}
      chown ${toString config.users.users.git.name} ${cfg.location}
      chgrp ${toString config.users.groups.git.name} ${cfg.location}
      chmod 755 ${cfg.location}
    '';

    # Public git viewer.
    services.cgit."git.linus.onl" = {
      enable = true;
      scanPath = cfg.location;
      settings = {
        root-title = "Linus' public projects";
        root-desc = "hello yes this is the git server";
        root-readme = toString ./about.html;
      };
      extraConfig = ''
        readme=:README.md
        readme=:README.rst
        readme=:README.text
        readme=:README.txt
        readme=:readme.md
        readme=:readme.rst
        readme=:readme.text
        readme=:readme.txt
      '';
    };

    # Register domain name.
    services.cloudflare-dyndns.domains = ["git.linus.onl"];

    # The CGit service creates the virtual host, but it does not enable ACME.
    services.nginx.virtualHosts."git.linus.onl" = {
      enableACME = cfg.useACME;
      forceSSL = cfg.useACME;
    };
  };
}
