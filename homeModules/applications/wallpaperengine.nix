{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.wallpaperengine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = false;
        description = "Enable Linux-WallpaperEngine. Wallpaper Engine must be installed via Steam.";
      };

      assetsPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/wallpaper_engine/assets";
        description = "Wallpaper Engine assets full path.";
      };

      wallpapers = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            wallpaperId = lib.mkOption { type = lib.types.str; };
            monitor = lib.mkOption { type = lib.types.str; };
            extraOptions = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
            silentAudio = lib.mkOption { type = lib.types.bool; default = true; };
          };
        });
        example = [
          {
            wallpaperId = "3295216327";
            monitor = "HDMI-A-1";
          }
        ];
        description = "List of wallpapers.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.wallpaperengine.enable {
    services.linux-wallpaperengine = {
      enable = true;
      assetsPath = config.homeManager.applications.wallpaperengine.assetsPath;
      wallpapers = map (w: {
        inherit (w) wallpaperId monitor extraOptions;
        audio.silent = w.silentAudio;
      }) config.homeManager.applications.wallpaperengine.wallpapers;
    };
  };
}