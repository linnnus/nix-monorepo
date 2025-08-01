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
  "cloudflare-ddns-token.env.age".publicKeys = [decodingKeys.ahmed] ++ interactiveKeys;
  "cloudflare-acme-token.env.age".publicKeys = [decodingKeys.ahmed] ++ interactiveKeys;
  "mullvad-wg.key.age".publicKeys = [decodingKeys.muhammed decodingKeys.ahmed] ++ interactiveKeys;
  "blog-github-secret.txt.age".publicKeys = [decodingKeys.ahmed] ++ interactiveKeys;
  "wireguard-keys/ahmed.age".publicKeys = [decodingKeys.ahmed] ++ interactiveKeys;
  "wireguard-keys/muhammed.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
  "syncthing-keys/muhammed/key.pem.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
  "syncthing-keys/muhammed/cert.pem.age".publicKeys = [decodingKeys.muhammed] ++ interactiveKeys;
  "syncthing-keys/ahmed/key.pem.age".publicKeys = [decodingKeys.ahmed] ++ interactiveKeys;
  "syncthing-keys/ahmed/cert.pem.age".publicKeys = [decodingKeys.ahmed] ++ interactiveKeys;
}
