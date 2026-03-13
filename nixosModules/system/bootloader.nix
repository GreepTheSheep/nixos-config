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
      timeout = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Durée en secondes si pas d'input avant de lancer la première entrée. (une valeur a 0 va sauter le choix de l'entrée)";
      };
      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Config Limine supplémentaires.";
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

      extraConfig = ''
        timeout: ${toString config.nixos.system.bootloader.timeout}
      '' + config.nixos.system.bootloader.extraConfig;

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
          "${../../wallpaper/nuzi.jpg}"
        ];
        wallpaperStyle = "centered";
        interface.helpHidden = true;
      };
    };
  };
}