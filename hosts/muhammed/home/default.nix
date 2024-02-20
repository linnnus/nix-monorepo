# Here we extend the HM user defined in `home/default.nix`. All the global HM
# stuff is defined in there.
{...}: {
  home-manager.users.linus = {
    imports = [
      ./iterm2
      ./noweb
    ];
  };
}
