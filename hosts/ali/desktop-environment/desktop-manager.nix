{
  services.xserver = {
    desktopManager = {
      xterm.enable = false;

      xfce.enable = true;
    };
  };

  services.displayManager.defaultSession = "xfce";
}
