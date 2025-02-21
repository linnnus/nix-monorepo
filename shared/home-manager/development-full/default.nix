# This module pulls in everything development related. Including it will give a
# fully featured development environment with all the bells and whistles. It
# will also explode the closure size, so this shouldn't be included on every
# host!
{...}: {
  imports = [
    ../C
    ../development-minimal
    ../javascript
    ../nix
    ../noweb
    ../python
    ../rust
    ../svelte
  ];
}
