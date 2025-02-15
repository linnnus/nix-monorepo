{...}: {
  services.openssh.enable = true;

  # Allow incomming connections from the VM host.
  users.users.linus.openssh.authorizedKeys.keyFiles = [(toString ../keys/ssh_vmhost_ed25519_key.pub)];

  # Don't generate any host keys automatically. We will use these hardcoded
  # ones instead. Storing keys in plaintext would normally be SUPER SUPER BAD
  # but in this case it doesn't matter, since it's just a local VM.
  services.openssh.hostKeys = [];

  # Install the very public private key.
  environment.etc = {
    # Note the seemingly reversed file names: "host" in this filename is relative to the VM guest.
    "ssh/ssh_host_ed25519_key" = {
      mode = "0600";
      source = ../keys/ssh_vmguest_ed25519_key;
    };
    "ssh/ssh_host_ed25519_key.pub" = {
      mode = "0644";
      source = ../keys/ssh_vmguest_ed25519_key.pub;
    };
  };
}
