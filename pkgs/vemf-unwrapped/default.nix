{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "vemf-unwrapped";
  version = "12-06-2024"; # date of commit

  src = fetchFromGitHub {
    owner = "selaere";
    repo = "vemf";
    rev = "3a3798cbdfacfe35465b90a831e1214907f6a5e2";
    hash = "sha256-7mmphu2XUwwsCUxqrXN2x5B4FEgZM2ZYyvWlZQiPoao=";
  };

  cargoHash = "sha256-h8TOs7r3S1U3RuJwLv5X5SSaVliKsAYDf/QpjEfdBHw=";

  # The actual interpreter is only built when the 'bin' feature is enabled.
  # See: https://github.com/selaere/vemf/tree/3a3798cbdfacfe35465b90a831e1214907f6a5e2?tab=readme-ov-file#building
  noDefaultFeatures = true;
  buildFeatures = ["bin"];

  meta = with lib; {
    description = "not good golfing programming language";
    license = licenses.mit;
    homepage = "https://selaere.github.io/vemf/doc/docs.html";
  };
}
