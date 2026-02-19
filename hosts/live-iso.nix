{ lib, ... }:

{
  system.stateVersion = "25.11";
  networking.hostName = "greep-nixos-live-iso";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
