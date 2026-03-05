{ lib, ... }:

{
  homeManager.applications = {
    enable = true;

    communication.enable = lib.mkForce false;
    editing.enable = lib.mkForce false;
    office.enable = lib.mkForce false;
    sync.enable = lib.mkForce false;
    screenshot.enable = lib.mkForce false;

    media = {
      audio.enable = lib.mkForce false;
      jellyfin.enable = lib.mkForce false;
      mpv.enable = lib.mkForce false;
      obs-studio.enable = lib.mkForce false;
      qbittorrent.enable = lib.mkForce false;
    };

    development = {
      antigravity.enable = true;
      claudecode.enable = true;
    };
  };
}