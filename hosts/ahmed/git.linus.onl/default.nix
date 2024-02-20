{
  config,
  pkgs,
  metadata,
  ...
}: let
  git-shell = "${pkgs.gitMinimal}/bin/git-shell";

  # Enables HTTPS stuff.
  useACME = true;

  # Where repositories will be stored.
  location = "/srv/git";
in {
  config = {
    # Create a user which
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
          metadata.hosts.muhammed.sshPubKey
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
    services.cgit."git.linus.onl" = {
      enable = true;
      scanPath = location;
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
      enableACME = useACME;
      forceSSL = useACME;
    };
  };
}
