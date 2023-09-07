# This file indexes all services. Services are different from use-cases in that
# they are reusable components that (most probably one). These are NixOS
# modules, NOT home-manager modules.

{ ... }:

{
  imports =
    [
      ./on-demand-minecraft
    ];
}
