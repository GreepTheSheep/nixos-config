{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
    ./configuration.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
