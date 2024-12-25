# This module configures wireless networking using WPA.

{...}:

{
  # Enables wireless support via wpa_supplicant.
  networking.wireless.enable = true;

  # wpa_supplicant needs a configuration file. That file contains plaintext
  # passwords and should NOT be added to the configuration. Instead, let's
  # store it persistently.
  #
  # I created that file with the following commands:
  #   mkdir -p /persist/etc/
  #   echo '# Allow frontend (e.g. wpa_cli) to be used by all users in 'wheel' group.
  #   ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel' >/persist/etc/wpa_supplicant.conf
  # And then I added the network={} blocks for the networks I know.
  environment.etc."wpa_supplicant.conf".source = "/persist/etc/wpa_supplicant.conf";
}
