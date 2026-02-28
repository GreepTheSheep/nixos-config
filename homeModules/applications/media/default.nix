{ config, lib, ... }:

{
  imports = [
    ./audio.nix
    ./ffmpeg.nix
    ./jellyfin.nix
    ./mediaplayer.nix
    ./mpv.nix
    ./obs-studio.nix
    ./yt-dlp.nix
  ];

  options.homeManager = {
    applications.media = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable media modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.media.enable {
    homeManager.applications.media = {
      audio.enable = true;
      ffmpeg.enable = true;
      jellyfin.enable = true;
      mediaplayer.enable = true;
      mpv.enable = true;
      obs-studio.enable = true;
      yt-dlp.enable = true;
    };
  };
}