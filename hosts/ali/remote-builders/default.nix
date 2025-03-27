{
  imports = [
    ./ahmed-builder.nix
  ];

  # Our interactive user must be trusted in order to use remote builders. I
  # guess this is because otherwise an untrusted user could use their own
  # remote builder to replace arbitrary store files...
  nix.settings.trusted-users = ["linus"];
}
