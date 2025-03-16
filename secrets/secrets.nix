# This file conatins configuration for the agenix CLI. It is not actually
# imported into the system cofniguration.
let
  metadata = builtins.fromTOML (builtins.readFile ../metadata.toml);
  ahmedKey = metadata.hosts.ahmed.sshPubKey;
  muhammedKey = metadata.hosts.muhammed.sshPubKey;
in {
  "cloudflare-ddns-token.env.age".publicKeys = [muhammedKey ahmedKey];
  "cloudflare-acme-token.env.age".publicKeys = [muhammedKey ahmedKey];
  "duksebot.env.age".publicKeys = [muhammedKey ahmedKey];
  "mullvad-wg.key.age".publicKeys = [muhammedKey ahmedKey];
  "wraaath-sftp-password.txt.age".publicKeys = [muhammedKey ahmedKey];
  "linus.onl-github-secret.txt.age".publicKeys = [muhammedKey ahmedKey];
}
