# This module sets up a development VM which I use for developing Linux stuff
# on this Darwin host.
{
  lib,
  pkgs,
  flakeInputs,
  flakeOutputs,
  metadata,
  ...
}: let
  workingDirectory = "/var/lib/dev-vm";

  # Port 22 on the guest is forwarded to this port on the host.
  port = 31023;

  guest-system = import "${pkgs.path}/nixos" {
    configuration = {
      imports = [
        {
          _module.args = {
            hostPkgs = pkgs;
            hostPort = port;
            inherit workingDirectory flakeInputs flakeOutputs metadata;
          };
        }
        flakeInputs.home-manager.nixosModules.home-manager
        flakeInputs.agenix.nixosModules.default
        ./configuration/configuration.nix
      ];
    };
    system = builtins.replaceStrings ["darwin"] ["linux"] pkgs.stdenv.hostPlatform.system;
  };
in {
  system.activationScripts.preActivation.text = ''
    mkdir -p ${lib.escapeShellArg workingDirectory}
  '';

  launchd.agents.dev-vm = {
    script = ''
      # create-builder uses TMPDIR to share files with the builder, notably certs.
      # macOS will clean up files in /tmp automatically that haven't been accessed in 3+ days.
      # If we let it use /tmp, leaving the computer asleep for 3 days makes the certs vanish.
      # So we'll use /run/org.nixos.dev-vm instead and clean it up ourselves.
      export TMPDIR=/run/org.nixos.dev-vm
      export USE_TMPDIR=1

      rm -rf "$TMPDIR"
      mkdir -p "$TMPDIR"
      trap 'rm -rf "$TMPDIR"' EXIT

      ${guest-system.config.system.build.macos-vm-installer}/bin/create-builder
    '';

    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      WorkingDirectory = workingDirectory;
    };
  };

  environment.etc."ssh/ssh_config.d/100-dev-vm.conf".text = ''
    Host ${guest-system.config.networking.hostName}
      User linus # Also hardcoded in `configuration.nix`.
      Hostname localhost
      Port ${toString port}
      IdentityFile ${./keys/ssh_vmhost_ed25519_key}
  '';
}
