# This file specifies a home-manager config for basic development CLI
# applications like interpreters and such.

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    deno
  ];
}
