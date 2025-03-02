{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  # https://github.com/EdwinHoksberg/beanstalkd-cli
  pname = "beanstalkd-cli";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "EdwinHoksberg";
    repo = pname;
    rev = version;
    hash = "sha256-k4UK+OpYEW9YffWIf2qGzIpkZSVnLLdeT6uARHdTxI0=";
  };

  vendorHash = "sha256-2rNd9MxMJEflJp+r1mbjmXo1EV+j2SYjr0w1rMZ1bIA=";
}
