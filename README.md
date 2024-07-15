# Linus' Nix monorepo

This directory contains the monorepo which I use to manage my (very small) Nix
fleet.

## Structure

The following is a structured explanation of important directories and files.
Most files also contain a little comment at the top, explaining what it does.

* `/hosts/`: Each subdirectory in this directory contains the configuration
  entrypoint for a host, i.e. a `configuration.nix`. Some hosts use NixOS while
  others use [nix-darwin]. Every host directory contains subdirectories for
  services and modules.
  * `/hosts/ahmed/`: Mediocre home-server which runs most of my self-hosted services.
  * `/hosts/muhammed/`: My personal laptop used for development.
  * `/hosts/fatima/`: NAS
  * `/hosts/common.nix`: Common configuration options shared by all hosts.
    Every `configuration.nix` imports this file. It contains basic stuff like
    making `zsh` the default shell.
* `/home/`: Contains the part of my [home-manager] configuration that is common
  to all hosts. This includes basic stuff like `zsh` plugins. It is matched by
  `/hosts/<host>/home` which contains host-specific home-manager configuration.
* `/modules/`: Contains reusable modules that are configurable using [NixOS's
  module system][mod-sys] and are exported for other consumers via `flake.nix`.
  * `/modules/nixos/`: Every subdirectory in this directory contains a NixOS
    module. These are indexed in the attrset in `/modules/nixos/default.nix` and are exported as `outputs.nixosModules` in `flake.nix`.
  * `/modules/nixos/`: Every subdirectory in this directory contains a nix-darwin
    module. These are indexed in the attrset in `/modules/darwin/default.nix` and are exported as `outputs.darwinModules` in `flake.nix`.
  * `/modules/nixos/`: Every subdirectory in this directory contains a home-manager
    module. These are indexed in the attrset in `/modules/home-manager/default.nix` and are exported as `outputs.homeModules` in `flake.nix`.
* `/overlays/`: Contains [NixOS overlays][overlays] which update package
  versions and fix bugs used in the repo. These are exported as
  `outputs.overlays.modifications` in `flake.nix`.
* `/pkgs/`: Contains Nix packages which I haven't upstreamed into `nixpkgs` for
  some reason. `/pkgs/default.nix` lists out every package. These are also
  exported in `flake.nix`. An overlay that adds all new packages is also
  available as `outputs.overlays.additions`.
* `/secrets`: All files which can't be added to the world-readable Nix-store
  are managed by [agenix].
  * `/secrets/secrets.nix`: The only Nix file which isn't (indirectly) imported
    by `flake.nix`. This one is instead read by the `agenix` cli when editing
    or adding secrets.

    Since secrets aren't specified in `secrets.nix`, they must be imported by
    some other means. They are simply specified by `age.secrets.<name>.file`.
    See `/hosts/ahmed/torrenting/wireguard.nix` for an example or `grep -rn 'age\.secrets'`.

[nix-darwin]: https://github.com/LnL7/nix-darwin/tree/master
[home-manager]: https://github.com/nix-community/home-manager
[mod-sys]: https://wiki.nixos.org/wiki/NixOS_modules
[overlays]: https://wiki.nixos.org/wiki/Overlays
[agenix]: https://github.com/ryantm/agenix
