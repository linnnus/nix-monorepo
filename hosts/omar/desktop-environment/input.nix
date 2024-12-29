{

  # Configure keymap in X11
  services.xserver.xkb.layout = "dk";
  services.xserver.xkb.options = "caps:escape";

  console.useXkbConfig = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
}
