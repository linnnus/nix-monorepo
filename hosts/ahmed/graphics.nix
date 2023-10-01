# This module configures a basic graphical environment. I use this sometimes for
# ahmed when muhammed is being repaired.

{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.modules.graphics;
in
{
  options.modules.graphics.enable = mkEnableOption "basic graphical environment";

  config = mkIf cfg.enable {
    services.xserver.enable = true;

    # Match console keyboard layout but swap capslock and escape.
    # TODO: Create a custom keymap with esc/capslock swap so console can use it.
    services.xserver.layout = config.console.keyMap;
    services.xserver.xkbOptions = "caps:swapescape";

    # Enable touchpad support.
    services.xserver.libinput.enable = true;

    services.xserver.windowManager.dwm.enable = true;

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    environment.systemPackages = with pkgs; [
      st    # suckless terminal - dwm is pretty sucky without this
      dmenu # application launcher
    ];
  };
}
