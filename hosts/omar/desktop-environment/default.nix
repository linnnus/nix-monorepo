# This module configures a desktop environment specific to this host.

{pkgs, ...}:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.windowManager.dwm.enable = true;

  systemd.services.dwm-battery = {
    description = "Battery status update";
    after = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];

    serviceConfig = {
      script = ''
        while true; do
          echo "$(date +%H:%M) - $(cat /sys/class/power_supply/BAT0/capacity)"
          sleep 5
        done | ${pkgs.dwm-setstatus}/bin/dwm-setstatus
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    st
    dmenu
  ];

  # Configure keymap in X11
  services.xserver.xkb.layout = "dk";
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
}
