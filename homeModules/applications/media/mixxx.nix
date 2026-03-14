{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.media.mixxx = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable mixxx.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.media.mixxx.enable {
    home.packages = with pkgs; [
      mixxx
    ];
  };
}