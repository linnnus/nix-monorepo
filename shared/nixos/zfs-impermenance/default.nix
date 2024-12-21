# This module sets up basic impermenance the way I like to do it on my ZFS
# hosts. It assumes there is a main zpool called rpool, which has a dataset
# `rpool/local/root` mounted at `/`, and that the dataset has an empty dataset
# called `@blank`.
#
# Here is the dataset structure I use:
#
#    rpool
#    ├── local
#    │   ├── nix (atime=off, mountpoint=/nix)
#    │   └── root (mountpoint=/)
#    └── safe
#        ├── home (mountpoint=/home)
#        └── persist (mountpoint=/persist)
#
# I usually follow the convention that `rpool/local` isn't backed up and
# `rpool/safe` is.
#
# See: https://grahamc.com/blog/erase-your-darlings/
{lib, ...}: {
  # Reset / to empty on boot. This is what achieves the impermenance.
  # Unlike the holy book (the linked article), I had to use `postResumeCommands`
  # as this is the step where ZFS imports the dataset (but doesnt't mounted it yet).
  # See: https://github.com/NixOS/nixpkgs/blob/b681065d0919f7eb5309a93cea2cfa84dec9aa88/nixos/modules/tasks/filesystems/zfs.nix#L627-L659
  boot.initrd.postResumeCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  # Filesystems with mountpoints at `/` and `/nix` are automatically mounted at boot,
  # but `/persist` is bespoke, so we have to teach init about that one ourselves.
  fileSystems."/persist".neededForBoot = true;
}
