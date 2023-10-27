{
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin rec {
  pname = "vim-crystal";
  version = "15-04-2023"; # day of commit

  src = fetchFromGitHub {
    owner = "vim-crystal";
    repo = pname;
    rev = "dc21188ec8c2ee77bb81dffca02e1a29d87cfd9f";
    hash = "sha256-uGtPMgMt+s0GSQvpvo97diYOfhIf+pNuOQiGQ17I9uQ=";
  };
}
