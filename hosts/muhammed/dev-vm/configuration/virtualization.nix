{
  hostPkgs,
  hostPort,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  virtualisation.host = {pkgs = hostPkgs;};

  # DNS fails for QEMU user networking (SLiRP) on macOS.
  #
  # This works around that by using a public DNS server other than the DNS
  # server that QEMU provides (normally 10.0.2.3)
  #
  # See: https://github.com/utmapp/UTM/issues/2353
  networking.nameservers = ["8.8.8.8"];

  # System is deployed by image.
  system.disableInstallerTools = true;

  virtualisation.forwardPorts = [
    {
      from = "host";
      guest.port = 22;
      host.port = hostPort;
    }
  ];

  # We will be connecting over SSH.
  virtualisation.graphics = false;

  # When the Nix store is shared with the VM host via 9p (the default) and the
  # VM host is a Darwin system with the store mounted on a case-insensitive
  # APFS volume (also the default), the case-hack will be visible on the guest.
  #
  # With NixOS/nixpkgs#347636 this is fixed for store images, but not for the
  # 9P protocol. So for now we will use that as a temporary fix.
  #
  # See: https://github.com/NixOS/nix/issues/9319
  # See: https://nix.dev/manual/nix/2.24/command-ref/conf-file.html#conf-use-case-hack
  virtualisation.useNixStoreImage = true;
  virtualisation.writableStore = true; # Only default for mounted store.
}
