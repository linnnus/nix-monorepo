# This file conatins configuration for the agenix CLI. It is not actually
# imported into the system cofniguration.
let
  metadata = builtins.fromTOML (builtins.readFile ../metadata.toml);

  # Keys used for editing secrets on interactive hosts.
  interactiveKeys = [
    metadata.hosts.ahmed.sshKeys.linus
    metadata.hosts.muhammed.sshKeys.linus
    metadata.hosts.ali.sshKeys.linus
  ];

  # These are the keys which are used when actually decoding the secrets as part of activation.
  # On NixOS hosts this is the root user, and on nix-darwin hosts it's the user who installed nix-darwin.
  decodingKeys = {
    ahmed = metadata.hosts.ahmed.sshKeys.root;
    muhammed = metadata.hosts.muhammed.sshKeys.linus;
    ali = metadata.hosts.ali.sshKeys.root;
  };
in {
  "cloudflare-ddns-token.env.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
  "cloudflare-acme-token.env.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
  "duksebot.env.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
  "mullvad-wg.key.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
  "wraaath-sftp-password.txt.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
  "linus.onl-github-secret.txt.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
  "wireguard-keys/ahmed.age".publicKeys = [decodingKeys.ahmed] ++ interactiveKeys;
  "wireguard-keys/muhammed.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
}
