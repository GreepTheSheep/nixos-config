{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.gaming.parsec = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Parsec.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.gaming.parsec.enable {
    home.packages = with pkgs; [
      parsec-bin
    ];
  };
}