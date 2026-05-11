{ config, lib, pkgs, ... }:

{
  options.nixos = {
    base.tools.scrcpy = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable scrcpy.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.tools.scrcpy.enable {
    environment.defaultPackages = with pkgs; [
      scrcpy
    ];
  };
}