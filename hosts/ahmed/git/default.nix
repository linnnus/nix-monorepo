{
  config,
  pkgs,
  metadata,
  lib,
  ...
}: let
  domain = "git.${metadata.domains.personal}";

  git-shell = "${pkgs.gitMinimal}/bin/git-shell";

  # Enables HTTPS stuff.
  useACME = true;

  # Where repositories will be stored.
  location = "/srv/git";
in {
  config = {
    # Create a user which will own (i.e. have rw access to) the git repositories.
    # See: https://git-scm.com/book/en/v2/Git-on-the-Server-Setting-Up-the-Server
    users.users.git = {
      description = "Git server user";
      isSystemUser = true;
      group = "git";

      # FIXME: Is serving the home-directory of a user (indirectly through CGit) a bad idea?
      home = location;
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
          # The user's own SSH key is used when the Git CLI connects to the server.
          metadata.hosts.muhammed.sshKeys.linus
          metadata.hosts.ali.sshKeys.linus
        ];
    };
    users.groups.git = {};

    environment.shells = [git-shell];

    # Create repo directory. It must be readable to NGINX.
    # NOTE: If location != "/srv/git" you may want to change this!
    # See: https://git.zx2c4.com/cgit/about/faq#why-doesnt-cgit-findshow-my-repo
    system.activationScripts.create-cgit-scan-path = ''
      mkdir -p ${location}
      chown ${toString config.users.users.git.name} ${location}
      chgrp ${toString config.users.groups.git.name} ${location}
      chmod 755 ${location}
    '';

    # Public git viewer.
    services.cgit.${domain} = {
      enable = true;

      # This CGit instance and the fcgiwrap instance coupled to this CGit
      # instance will use this unpriveledged user to access the world readable
      # git repositories. This is fine as they only need read access.
      # See: https://discourse.nixos.org/t/51419
      user = "cgit";
      group = "cgit";

      scanPath = location;
      settings = let
        package = config.services.cgit.${domain}.package;
      in {
        root-title = "Linus' public projects";
        root-desc = "hello yes this is the git server";
        root-readme = toString ./about.html;

        source-filter = "${package}/lib/cgit/filters/syntax-highlighting.py";
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
    services.cloudflare-dyndns.domains = [domain];

    services.nginx.virtualHosts.${domain} = {
      # The CGit service creates the virtual host, but it does not enable ACME.
      enableACME = useACME;
      forceSSL = useACME;

      # Monkey-patch the version of Git used by CGit to handle requests.
      locations."~ /.+/(info/refs|git-upload-pack)".fastcgiParams = {
        SCRIPT_FILENAME = lib.mkForce "${pkgs.git.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              ./no-ownership-check-for-root.patch
            ];
        })}/libexec/git-core/git-http-backend";
        GIT_NO_CHECK_OWNERSHIP = "1";
      };
    };
  };
}
