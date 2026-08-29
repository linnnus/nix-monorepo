# Create a local Linux builder. This will allow us to build aarch64-linux
# and x86_64-linux targets directly on this machine.
{
  services.nix-linux-builder = {
    enable = true;
    verbose = true;
  };
}
