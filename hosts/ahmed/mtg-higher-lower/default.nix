{
  flakeInputs,
  metadata,
  pkgs,
  ...
}: let
  domain = "mtg." + metadata.domains.personal;

  # Enable HTTPS stuff.
  useACME = true;
in {
  services.nginx = {
    virtualHosts.${domain} = {
      enableACME = useACME;
      forceSSL = useACME;

      root = "${flakeInputs.mtg-higher-lower.packages.${pkgs.system}.site}";
    };
  };
}
