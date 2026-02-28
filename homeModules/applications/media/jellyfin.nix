{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.media.jellyfin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Jellyfin Desktop.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.media.jellyfin.enable {
    home.packages = with pkgs; [
      jellyfin-desktop
    ];
  };
}