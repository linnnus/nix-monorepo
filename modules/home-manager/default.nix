# This file indexes all home manager modules. Note that there is no
# general/personal distinction here, as all personal home-manager configuration
# goes in home/ instead.
{
  iterm2 = import ./iterm2;
  git-credential-lastpass = import ./git-credential-lastpass;
  assert-valid-neovim-config = import ./assert-valid-neovim-config;
}
