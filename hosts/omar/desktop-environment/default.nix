# This module configures a desktop environment specific to this host.

{
  imports = [
    ./window-manager.nix
    ./input.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };
}
