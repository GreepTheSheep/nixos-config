{ config, lib, ... }:

{
  options.nixos.hardware.openrazer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable OpenRazer.";
    };
  };

  config = lib.mkIf config.nixos.hardware.openrazer.enable {
    hardware.openrazer = {
      enable = true;
      users = [
        config.nixos.system.user.defaultuser.name
      ];
      keyStatistics = true;
      batteryNotifier = {
        percentage = 10;
      };
    };
  };
}
