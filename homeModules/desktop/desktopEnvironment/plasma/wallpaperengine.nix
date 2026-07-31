{ config, lib, ... }:

let
  cfg = config.homeManager.desktop.desktopEnvironment.plasma.wallpaperengine;

  pluginId = "com.github.catsout.wallpaperEngineKde";

  pluginConfig = workshopId: {
    plugin = pluginId;
    config.General = {
      SteamLibraryPath = cfg.steamLibraryPath;
      WallpaperWorkShopId = workshopId;
      MuteAudio = cfg.muteAudio;
      Fps = cfg.fps;
    };
  };
in
{
  options.homeManager = {
    desktop.desktopEnvironment.plasma.wallpaperengine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Use the KDE wallpaper-engine-plugin for animated wallpapers (desktop and lock screen).";
      };

      steamLibraryPath = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/.local/share/Steam";
        example = "/home/user/.local/share/Steam";
        description = "Path to the Steam library containing the Wallpaper Engine workshop content.";
      };

      wallpaperId = lib.mkOption {
        type = lib.types.str;
        example = "3295216327";
        description = "Steam Workshop ID of the wallpaper to display on the desktop.";
      };

      lockWallpaperId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "3736914589";
        description = "Steam Workshop ID of the wallpaper to display on the lock screen. When null, the desktop wallpaper is reused.";
      };

      muteAudio = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Mute wallpaper audio.";
      };

      fps = lib.mkOption {
        type = lib.types.int;
        default = 15;
        description = "Maximum FPS for wallpaper rendering.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.plasma = {
      workspace = {
        wallpaper = lib.mkForce null;
        wallpaperCustomPlugin = pluginConfig cfg.wallpaperId;
      };

      kscreenlocker.appearance = {
        wallpaper = lib.mkForce null;
        wallpaperCustomPlugin = pluginConfig (
          if cfg.lockWallpaperId != null then cfg.lockWallpaperId else cfg.wallpaperId
        );
      };
    };
  };
}