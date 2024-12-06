# Create a local Linux builder. This will allow us to build aarch64-linux
# targets directly on this machine.
{...}: {
  # XXX: Why is this necessary?
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
        pkgs.cntr

        # Nix is used to debug and fetch other tools as needed.
        pkgs.nix
      ];

      # Allow root login. This would normally be horrible but it's a local VM so who cares.
      users.users.root.hashedPassword = "$y$j9T$TosKLKCZ.g9be.Wz5/qVJ.$YWvn4nAp8tn.xhHGBMOz748PHma6QGhN/WShilEbz8A";
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
