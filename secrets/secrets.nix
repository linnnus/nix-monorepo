# This file conatins configuration for the agenix CLI. It is not actually
# imported into the system cofniguration.

let
  metadata = builtins.fromTOML (builtins.readFile ../metadata.toml);
  publicKeys = map (builtins.getAttr "sshPubKey") (builtins.attrValues metadata.hosts);
in
{
  "cloudflare-ddns-token.age".publicKeys = publicKeys;
}
