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
{...}: {
  # User must be trusted in order to use the Linux builder.
  nix.settings.trusted-users = ["linus"];

  nix.linux-builder = {
    enable = true;

    # Clearing the VM state upon startup should improve reliability at the cost
    # of some startup speed. Will have to re-evaluate if this trade off is
    # worth it at some point.
    ephemeral = true;

    config = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        # cntr is used to jump into the sandbox of packages that use breakpointHook.
        cntr
      ];

      nix.enable = true;

      # Allow root login. This would normally be horrible but it's a local VM so who cares.
      users.users.root.password = "root";
      services.openssh.permitRootLogin = "yes";
    };
  };

  # Add system-features to the nix daemon that are needed for NixOS tests
  # Starting with Nix 2.19, this will be automatic
  nix.settings.system-features = [
    "nixos-test"
    "apple-virt"
  ];
}
