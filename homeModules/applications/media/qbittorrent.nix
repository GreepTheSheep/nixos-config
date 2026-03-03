{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.media.qbittorrent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable qBittorrent.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.media.qbittorrent.enable {
    home.packages = with pkgs; [
      qbittorrent
    ];
  };
}