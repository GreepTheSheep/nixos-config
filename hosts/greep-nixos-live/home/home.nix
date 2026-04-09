{ lib, ... }:

{
  homeManager.applications = {
    enable = true;
    development.bottles.enable = lib.mkForce false;
    media = {
      jellyfin.enable = lib.mkForce false;
      mixxx.enable = lib.mkForce false;
      qbittorrent.enable = lib.mkForce false;
      ytmdesktop.enable = lib.mkForce false;
    };

    sync.deskflow.enable = true;
    sync.kdeconnect.enable = lib.mkForce false;
  };
}