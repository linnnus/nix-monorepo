# This file registers ahmed as a remote x86_64-linux builder.
#
# You can test that the remote builder is working with this command:
#
#   nix build \
#   --max-jobs 0 \
#   --rebuild \
#   --expr 'derivation { name = "hello"; system = "x86_64-linux"; builder = "/bin/sh"; args = [ "-c" "echo hello >$out" ]; }'
#
# See: https://nixos.wiki/wiki/Distributed_build
# See: hosts/ahmed/remote-builder/default.nix
# FIXME: How to trust key ahead of time?
{metadata, ...}: let
  inherit (metadata.hosts.ahmed) ipv4Address;
in {
  nix.buildMachines = [
    {
      protocol = "ssh-ng";
      hostName = "ahmed-builder";

      system = "x86_64-linux";
      maxJobs = 1;
      speedFactor = 1;
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      mandatoryFeatures = [];
    }
  ];

  environment.etc."ssh/ssh_config.d/100-ahmed-builder.conf".text = ''
    Host ahmed-builder
      User remotebuilder
      Hostname ${ipv4Address}
      HostKeyAlias ahmed-builder
      # This matches `users.users.<builder>.authorizedKeys` on the server-side.
      # HACK: We should use a purpose-specific key.
      IdentityFile /Users/linus/.ssh/id_rsa
  '';

  # We have to trust ahmeds public key or the Nix daemon will fail to connect.
  programs.ssh.knownHosts = {
    ahmed-builder = {
      hostNames = ["ahmed-builder"];
      # This is the public key of remotebuilder on the remote machine.
      # It was obtained by manually connecting to remotebuilder@${ipAddress} and trusting the key.
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOodiSwTcZcaZxqLyHjI2MGe1CpIBvIzzbjpXrwAyiYO";
    };
  };
}
