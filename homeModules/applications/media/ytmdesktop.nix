{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.media.ytmdesktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable youtube music desktop.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.media.ytmdesktop.enable {
    home.packages = with pkgs; [
      ytmdesktop
    ];
  };
}