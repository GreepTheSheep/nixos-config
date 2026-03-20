# Configuration matérielle pour Raspberry Pi 5 (BCM2712)
# Le module nixos-hardware.nixosModules.raspberry-pi-5 (importé dans default.nix)
# configure déjà le kernel vendeur RPi et les modules de base.
# Ce fichier contient uniquement les overrides spécifiques à cet hôte.
{ lib, ... }:

{
  # Modules supplémentaires pour USB storage
  boot.initrd.availableKernelModules = [
    "usbhid"
    "usb_storage"
  ];

  # Paramètre requis pour le Bluetooth sur Pi 5
  boot.kernelParams = [ "8250.nr_uarts=11" ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
