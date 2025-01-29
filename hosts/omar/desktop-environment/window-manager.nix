{pkgs, ...}: {
  services.xserver.windowManager.dwm.enable = true;

  # Show battery and clock in status bar. This is a background daemon which
  # updates the root window, which DWM uses for status.
  systemd.user.services.dwm-battery = {
    description = "Battery status update";
    partOf = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];

    serviceConfig.ExecStart = pkgs.writeShellScript "dwm-battery" ''
      while true; do
        echo -n "$(date +%H:%M) - ";

        # See: https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-class-power
        case "$(cat /sys/class/power_supply/BAT0/status)" in
          Charging)       echo -n "🔋 " ;;
          Discharging)    echo -n "🪫 " ;;
          "Not charging") echo -n "🪫 " ;;
          Full)           echo -n "🔋 " ;;
          Unknown)        echo -n "? " ;;
          ""|*)           echo -n "?? " ;;
        esac

        echo -n "$(cat /sys/class/power_supply/BAT0/capacity)%"

        echo
        sleep 5
      done | ${pkgs.dwm-setstatus}/bin/dwm-setstatus
    '';
  };

  environment.systemPackages = with pkgs; [
    st
    dmenu
  ];
}
