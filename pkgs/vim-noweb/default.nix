{
  vimUtils,
  fetchzip,
}:
vimUtils.buildVimPlugin {
  pname = "vim-noweb";
  version = "23-03-2024"; # modification date on server
  src = fetchzip {
    url = "https://metaed.com/papers/vim-noweb/vim-noweb.tgz";
    hash = "sha256-ejNaEUFHj6xYc30pmgnVVAXaTUQTC5JCwSxxeSanC5k=";
  };
}
