# This module sets options to ensure a consistent Baseline Shell Experince™
# across the entire fleet.
#
# Most of the heavy lifting is done in `shared/nixos-and-darwin/common-shell-settings`.
# This module is limited to NixOS-specific settings.
{pkgs, ...}: {
  imports = [
    ../../nixos-and-darwin/common-shell-settings
  ];

  # There is not nix-darwin equivalent to this NixOS option.
  # The default shell on MacOS is already ZSH.
  users.defaultUserShell = pkgs.zsh;
}
