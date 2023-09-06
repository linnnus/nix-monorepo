# This file configures openSSH on this host.

{ config, pkgs, lib, misc, ... }:

{
  # Who is allowed/expected to connect to this machine?
  networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh = {
    enable = true;
    passwordAuthentication = false; 
  };

  users.users = lib.genAttrs ["root" "linus"] (_: {
    openssh.authorizedKeys.keys = 
      [
        misc.metadata.hosts.muhammed.sshPubKey
      ];
  });
}
