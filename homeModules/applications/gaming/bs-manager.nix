{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.gaming.bs-manager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable BSManager.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.gaming.bs-manager.enable {
    home.packages = with pkgs; [
      bs-manager
    ];
  };
}