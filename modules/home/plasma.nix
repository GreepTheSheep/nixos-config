{ lib, pkgs, ... }:

{
  imports = [
    ./plasma/general.nix
    ./plasma/panels.nix
    ./plasma/shortcuts.nix
  ];
}
