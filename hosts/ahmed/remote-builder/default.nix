{
  pkgs,
  metadata,
  ...
}: {
  # Create a user for remote builds.
  users.users.remotebuilder = {
    isNormalUser = true;
    createHome = false;
    group = "remotebuilder";

    # Allow SSH connections by the Nix client.
    openssh.authorizedKeys.keys = [
      # This is matched with the ssh config IdentityFile on the client-side.
      # TODO: Use root key!
      metadata.hosts.muhammed.sshKeys.linus
      metadata.hosts.ali.sshKeys.root
    ];
  };
  users.groups.remotebuilder = {};

  # This is indirectly equivalent to giving root as it allows this user to
  # replace store artifacts.
  #
  # See: https://nix.dev/manual/nix/2.25/command-ref/conf-file?highlight=system-features#conf-trusted-users
  nix.settings.trusted-users = ["remotebuilder"];
}
