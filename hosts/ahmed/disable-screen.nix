# This file defines some configuration options which disable the screen. This
# is only relevant because this host is an old laptop running as a server.

{ pkgs, config, lib, ... }:

let
  # The path to the device.
  device-path = "/sys/class/backlight/intel_backlight";

  # The systemd device unit which corresponds to `device-path`.
  device-unit = "sys-devices-pci0000:00-0000:00:02.0-drm-card0-card0\\x2deDP\\x2d1-intel_backlight.device";
in
{
  # Disable sleep on lid close.
  services.logind =
    let
      lidSwitchAction = "ignore";
    in
    {
      lidSwitchExternalPower = lidSwitchAction;
      lidSwitchDocked = lidSwitchAction;
      lidSwitch = lidSwitchAction;
    };

  # Don't store screen brightness between boots. We always want to turn off the
  # screen.
  #
  # See: https://wiki.archlinux.org/title/backlight#Save_and_restore_functionality
  # See: https://github.com/NixOS/nixpkgs/blob/990398921f677615c0732d704857484b84c6c888/nixos/modules/system/boot/systemd.nix#L97-L101
  systemd.suppressedSystemUnits = [ "systemd-backlight@.service" ];

  # FIXME: Figure out how to enable screen when on-device debugging is necessary.
  # Create a new service which turns off the display on boot.
  #
  # See: https://nixos.wiki/wiki/Backlight#.2Fsys.2Fclass.2Fbacklight.2F...
  # See: https://superuser.com/questions/851846/how-to-write-a-systemd-service-that-depends-on-a-device-being-present
  systemd.services.disable-screen =
    {
      requires = [ device-unit ];
      after = [ device-unit ];
      wantedBy = [ device-unit ];

      serviceConfig.Type = "oneshot";
      script = ''
        tee ${device-path}/brightness <<<0
      '';
    };

  warnings = lib.optional config.my.modules.graphics.enable
    "You have enabled a graphical environment but the screen is still being disabled";
}
