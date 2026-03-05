{ config, lib, ... }:

{
  options.nixos = {
    system.bootloader = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable limine Bootloader.";
      };
      extraBootEntries = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Entrées Limine supplémentaires par hôte (dual-boot, etc.).";
      };
    };
  };

  config = lib.mkIf config.nixos.system.bootloader.enable {

    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.efi.efiSysMountPoint = "/boot/";

    boot.loader.limine = {
      enable = true;
      efiSupport = true;
      enableEditor = false;
      maxGenerations = 32;
      validateChecksums = true;
      panicOnChecksumMismatch = true;

      extraEntries = config.nixos.system.bootloader.extraBootEntries + ''
        /Reboot
          protocol: reboot

        /Power Off
          protocol: poweroff

        /Firmware Setup
          protocol: fwsetup
      '';

      style = {
        wallpapers = [
          "${../../wallpaper/stolas.png}"
        ];
        interface.helpHidden = true;
      };
    };
  };
}