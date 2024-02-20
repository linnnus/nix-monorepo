# Here we extend the HM user defined in `home/default.nix`. All the global HM
# stuff is defined in there. The only imports here are specific to this host.
{...}: {
  home-manager.users.linus = {
    imports = [
      # empty for now
    ];
  };
}
