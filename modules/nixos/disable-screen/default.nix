# This file defines some configuration options which disable the screen. This
# is only relevant because this host is an old laptop running as a server.
{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.services.disable-screen;
in {
  options.services.disable-screen = {
    enable = mkEnableOption "disable screen";

    device-path = mkOption {
      description = "Path to the device in the `/sys` file system.";
      type = types.str;
      example = "/sys/class/backlight/intel_backlight";
    };

    device-unit = mkOption {
      description = "The systemd device unit that corresponds to the device speciefied in `device-path`.";
      type = types.str;
      example = "sys-devices-pci...-intel_backligt.device";
    };
  };

  config = {
    # Disable sleep on lid close.
    services.logind = let
      lidSwitchAction = "ignore";
    in {
      lidSwitchExternalPower = lidSwitchAction;
      lidSwitchDocked = lidSwitchAction;
      lidSwitch = lidSwitchAction;
    };

    # Don't store screen brightness between boots. We always want to turn off the
    # screen.
    #
    # See: https://wiki.archlinux.org/title/backlight#Save_and_restore_functionality
    # See: https://github.com/NixOS/nixpkgs/blob/990398921f677615c0732d704857484b84c6c888/nixos/modules/system/boot/systemd.nix#L97-L101
    systemd.suppressedSystemUnits = ["systemd-backlight@.service"];

    # FIXME: Figure out how to enable screen when on-device debugging is necessary.
    # Create a new service which turns off the display on boot.
    #
    # See: https://nixos.wiki/wiki/Backlight#.2Fsys.2Fclass.2Fbacklight.2F...
    # See: https://superuser.com/questions/851846/how-to-write-a-systemd-service-that-depends-on-a-device-being-present
    systemd.services.disable-screen = {
      requires = [cfg.device-unit];
      after = [cfg.device-unit];
      wantedBy = [cfg.device-unit];

      serviceConfig.Type = "oneshot";
      script = ''
        tee ${cfg.device-path}/brightness <<<0
      '';
    };
  };
}
