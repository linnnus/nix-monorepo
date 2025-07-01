# Create a local Linux builder. This will allow us to build aarch64-linux
# targets directly on this machine.
#
# Note that building the linux-builder requires having access to a linux
# builder already. To break this cycle, a version of the linux builder with
# `nix.linux-builder.config = {}` is cached on the official binary cache.
#
# If you do not have a linux builder available when switching to this
# configuration, you should start by commenting out all custom configuration of
# the VM and building that first.
{
  # User must be trusted in order to use the Linux builder.
  nix.settings.trusted-users = ["linus"];

  nix.linux-builder = {
    enable = true;
  };

  # Add system-features to the nix daemon that are needed for NixOS tests
  # Starting with Nix 2.19, this will be automatic
  nix.settings.system-features = [
    "nixos-test"
    "apple-virt"
  ];
}
