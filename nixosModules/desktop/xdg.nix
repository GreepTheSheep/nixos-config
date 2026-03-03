{ config, lib, pkgs, ... }:

let
  browser = [ "re.sonny.Junction.desktop;" ];
  chrome = [ "helium.desktop;" ];
  firefox = [ "firefox.desktop;" ];
  filemanager = [ "org.kde.dolphin.desktop;" ];
  #mediaplayer = [ "vlc.desktop;" ];
  videoplayer = [ "vlc.desktop;" ];
  musicplayer = [ "vlc.desktop;" ];
  pdfviewer = [ "re.sonny.Junction.desktop;" ];
  imageviewer = [ "org.kde.gwenview.desktop;" ];
  editor = [ "org.kde.kate.desktop;" ];
  discord = [ "discord.desktop;" ];
  vscode = [ "code.desktop;" ];
  antigravity = [ "antigravity.desktop;" ];

  associations = {
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/xhtml+xml" = browser;
    "x-scheme-handler/tg" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/chrome" = chrome;
    "x-scheme-handler/firefox" = firefox;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/unknown" = editor;
    "text/plain" = editor;
    "text/markdown" = editor;
    "text/html" = editor;
    "audio/*" = musicplayer;
    "video/*" = videoplayer;
    "image/*" = imageviewer;
    "application/json" = browser;
    "application/pdf" = pdfviewer;
    "x-scheme-handler/discord" = discord;
    "inode/directory" = filemanager;
    "x-scheme-handler/vscode" = vscode;
    "x-scheme-handler/antigravity" = antigravity;
  };
in

{
  options.nixos = {
    desktop.xdg = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable XDG Portal settings.";
      };
    };
  };

  config = lib.mkIf config.nixos.desktop.xdg.enable {
    xdg = {
      portal = {
        enable = true;
        wlr = {
          enable = true;
          #settings = {};
        };
        extraPortals = with pkgs; [
          xdg-desktop-portal
          #  xdg-desktop-portal-wlr
          kdePackages.xdg-desktop-portal-kde
          #  xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config.common.default = "kde";
        xdgOpenUsePortal = true;
      };

      mime = {
        enable = true;
        defaultApplications = associations;
        addedAssociations = associations;
      };

      autostart.enable = true;
    };
  };
}