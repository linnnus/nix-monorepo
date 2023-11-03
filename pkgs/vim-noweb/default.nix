{
  vimUtils,
  fetchzip,
}:
vimUtils.buildVimPlugin {
  pname = "vim-noweb";
  version = "26-08-2023"; # day of retrieval
  src = fetchzip {
    url = "https://metaed.com/papers/vim-noweb/vim-noweb.tgz";
    hash = "sha256-kZnbbRM6h1xVRb5Dp+QcmnvD4k0gCDIe7lMDdQRbBMg";
  };
}
