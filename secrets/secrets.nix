# This file conatins configuration for the agenix CLI. It is not actually
# imported into the system cofniguration.
let
  metadata = builtins.fromTOML (builtins.readFile ../metadata.toml);
  ahmedKey = metadata.hosts.ahmed.sshPubKey;
  muhammedKey = metadata.hosts.muhammed.sshPubKey;
in {
  "cloudflare-ddns-token.env.age".publicKeys = [muhammedKey ahmedKey];
  "duksebot.env.age".publicKeys = [muhammedKey ahmedKey];
  "mullvad-wg.key.age".publicKeys = [muhammedKey ahmedKey];
}
