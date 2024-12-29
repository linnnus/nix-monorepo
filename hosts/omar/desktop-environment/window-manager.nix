{pkgs, ...}:

{
  services.xserver.windowManager.dwm.enable = true;

  # Show battery and clock in status bar. This is a background daemon which
  # updates the root window, which DWM uses for status.
  systemd.user.services.dwm-battery = {
    description = "Battery status update";
    partOf = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];

    serviceConfig.ExecStart = pkgs.writeShellScript "dwm-battery" ''
        while true; do
          echo "$(date +%H:%M) - $(cat /sys/class/power_supply/BAT0/capacity)%"
          sleep 5
        done | ${pkgs.dwm-setstatus}/bin/dwm-setstatus
      '';
  };

  environment.systemPackages = with pkgs; [
    st
    dmenu
  ];
}
