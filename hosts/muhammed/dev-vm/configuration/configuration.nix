{
  config,
  lib,
  hostPkgs,
  workingDirectory,
  ...
}: {
  imports = [
    ../../../../shared/nixos/danish
    ../../../../shared/nixos/common-nix-settings
    ../../../../shared/nixos/common-shell-settings
    ../../../../shared/nixos-and-darwin/common-hm-settings

    ./virtualization.nix
    ./ssh.nix
    ./user.nix
  ];

  networking.hostName = "dev-vm";

  system.build.macos-vm-installer = hostPkgs.writeShellScriptBin "create-builder" ''
    set -euo pipefail

    ${lib.optionalString (workingDirectory != ".") ''
      # When running as non-interactively as part of a DarwinConfiguration the working directory
      # must be set to a writeable directory.
      ${hostPkgs.coreutils}/bin/mkdir --parent -- ${lib.escapeShellArg workingDirectory}
      cd -- ${lib.escapeShellArg workingDirectory}
    ''}

    ${lib.getExe config.system.build.vm}
  '';
}
