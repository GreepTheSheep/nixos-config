{ lib, pkgs, ... }:

{
  imports = [
    ./kde/general.nix
    ./kde/panels.nix
    ./kde/shortcuts.nix
  ];
}
