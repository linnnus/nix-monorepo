# This module configures various syntax/filetype plugins for Neovim.
{pkgs, ...}: let
  vim-noweb = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-noweb";
    version = "26-08-2023"; # day of retrieval
    src = pkgs.fetchzip {
      url = "https://metaed.com/papers/vim-noweb/vim-noweb.tgz";
      hash = "sha256-c5eUZiKIjAfjJ33l821h5DjozMpMf0CaK03QIkSUfxg=";
    };
  };
  vim-janet = pkgs.vimUtils.buildVimPlugin {
    pname = "janet.vim";
    version = "02-07-2023"; # day of commit

    src = pkgs.fetchFromGitHub {
      owner = "janet-lang";
      repo = "janet.vim";
      rev = "dc14b02f2820bc2aca777a1eeec48627ae6555bf";
      hash = "sha256-FbwatEyvvB4VY5fIF+HgRqFdeuEQI2ceb2MrZAL/HlA=";
    };

    nativeBuildInputs = [pkgs.janet];
  };
in {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # Filetype plugins
    vim-nix
    vim-noweb
    vim-janet
  ];
}
