{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
    ./bootloader.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./networking.nix
  ];
}
