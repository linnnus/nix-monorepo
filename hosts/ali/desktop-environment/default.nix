# This module configures a desktop environment specific to this host.
{pkgs, ...}: {
  imports = [
    ./window-manager.nix
    ./input.nix
  ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # TODO: We should be able to add "intel" driver?
    videoDrivers = ["fbdev"];
  };

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };
}
