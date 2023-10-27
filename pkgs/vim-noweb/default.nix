{
  vimUtils,
  fetchzip,
}:
vimUtils.buildVimPlugin {
  pname = "vim-noweb";
  version = "26-08-2023"; # day of retrieval
  src = fetchzip {
    url = "https://metaed.com/papers/vim-noweb/vim-noweb.tgz";
    hash = "sha256-c5eUZiKIjAfjJ33l821h5DjozMpMf0CaK03QIkSUfxg=";
  };
}
