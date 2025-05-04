# This module adds ahmed as a remote builder for ali.
# Note that ahmed is configured such that root@ali is allowed to connect to remotebuilder@ahmed.
# TODO: Dedublicate with hosts/muhammed/remote-builders/ahmed-builder.nix
{metadata, ...}: {
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
      Hostname ${metadata.hosts.ahmed.ipv4Address}
      HostKeyAlias ahmed-builder
  '';

  # We have to trust ahmeds host key or the Nix daemon will fail to connect.
  programs.ssh.knownHosts = {
    ahmed-builder = {
      hostNames = ["ahmed-builder"];
      publicKey = metadata.hosts.ahmed.sshKeys.root;
    };
  };
}
