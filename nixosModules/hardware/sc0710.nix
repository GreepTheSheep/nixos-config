# https://github.com/Nakildias/sc0710#nixos-flakes

{ config, lib, pkgs, sc0710, ... }:

{
  options.nixos.hardware.sc0710 = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable sc0710 support (Elgato 4K60 Pro MK.2 and 4K Pro drivers)";
    };

    enableFirmware = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable automatic firmware installation for Elgato 4K Pro (1cfa:0012)";
    };
  };

  config = lib.mkIf config.nixos.hardware.sc0710.enable {
    imports = [
      sc0710.nixosModules.default
    ];

    hardware.sc0710 = {
      enable = true;
      enableFirmware = nixos.hardware.sc0710.enableFirmware;
    };
  };
}