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

      enableRPC = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Jellyfin RPC, a module that displays the content you're currently watching on Discord. (Discord must be enabled to enable this)";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.media.jellyfin.enable {
    home.packages = with pkgs; [
      jellyfin-desktop
    ] ++ lib.optionals (config.homeManager.applications.media.jellyfin.enableRPC && config.homeManager.applications.communication.discord.enable) [
      jellyfin-rpc
    ];
  };
}