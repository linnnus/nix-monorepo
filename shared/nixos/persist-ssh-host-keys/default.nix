# This module ensures that SSH keys are not cleared on reboots.
# It assumes that `/` is ephemeral and `/persist` isn't.

{...}:

{
  services.openssh = {
    hostKeys = [
      {
        path = "/persist/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
}
