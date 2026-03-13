{ config, lib, ... }:

{
  options.nixos = {
    system.earlyoom = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable earlyoom.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.earlyoom.enable {
    services.earlyoom = {
      enable = true;
    };
  };
}