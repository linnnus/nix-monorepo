# This module should be imported on Danish hosts.
{lib, ...}: {
  i18n.defaultLocale = "da_DK.UTF-8";

  # Allow indirect overwriting via `console.useXkbConfig`.
  console.keyMap = lib.mkDefault "dk";
}
