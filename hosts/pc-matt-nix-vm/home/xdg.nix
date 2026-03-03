{ config, ... }:

{
  xdg.userDirs = {
    desktop = "${config.home.homeDirectory}/Bureau";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Musique";
    pictures = "${config.home.homeDirectory}/Images";
    videos = "${config.home.homeDirectory}/Videos";
  };
}