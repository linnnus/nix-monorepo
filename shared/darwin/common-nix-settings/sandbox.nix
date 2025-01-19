# This module enables building using the sandbox on Darwin.
{
  nix.settings.sandbox = "relaxed";

  # Fixes "pattern serialization length ┅ exceeds maximum (65535)" error when
  # building derivations that use a lot of paths.
  #
  # In the thread linked below, someone also suggested just building the
  # top-level system derivation with more lax sandboxing (via the hidden option
  # `system.systemBuilderArgs`), but that doesn't fix the large derivations
  # that HM builds. When nix-community/home-manager#3729 is merged, this
  # approach might become appropriate.
  #
  # The more selective approach described above would be preferable, since the
  # current solution partially negates the value of the store.
  #
  # See: https://github.com/NixOS/nix/issues/4119#issuecomment-2561973914
  # FIXME: Use the approach above when #3729 is merged.
  nix.settings.extra-sandbox-paths = [builtins.storeDir];
}
