# This file configures openSSH on this host.
{
  lib,
  metadata,
  ...
}: {
  # Who is allowed/expected to connect to this machine?
  networking.firewall.allowedTCPPorts = [22];
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users = lib.genAttrs ["root" "linus"] (_: {
    openssh.authorizedKeys.keys = [
      metadata.hosts.muhammed.sshPubKey
    ];
  });
}
