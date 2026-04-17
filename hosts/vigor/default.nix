_:

{
  imports = [
    ./containers

    ./auto-rebuild-reboot.nix
    ./bootloader.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./mount.nix
    ./networking.nix
  ];
}