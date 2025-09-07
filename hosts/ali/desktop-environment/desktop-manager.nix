{
  services.xserver = {
    desktopManager.xfce = {
      # Enable XFCE desktop manager. It will register itself via
      # `services.xserver.desktopManager.session` to become an option supported
      # by the display manager.
      enable = true;
    };
  };
}
