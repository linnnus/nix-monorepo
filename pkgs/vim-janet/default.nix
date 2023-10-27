{
  vimUtils,
  fetchFromGitHub,
  janet,
}:
vimUtils.buildVimPlugin {
  pname = "janet.vim";
  version = "02-07-2023"; # day of commit

  src = fetchFromGitHub {
    owner = "janet-lang";
    repo = "janet.vim";
    rev = "dc14b02f2820bc2aca777a1eeec48627ae6555bf";
    hash = "sha256-FbwatEyvvB4VY5fIF+HgRqFdeuEQI2ceb2MrZAL/HlA=";
  };

  nativeBuildInputs = [janet];
}
