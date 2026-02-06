{ config, lib, ... }:

{
  appimages.apps.helium = {
    enable = true;
    
    # Télécharge automatiquement la dernière version depuis GitHub
    githubRepo = "imputnet/helium-linux";
    githubAssetPattern = "x86_64.AppImage";
    
    filename = "helium.AppImage";
    autoUpdate = false;

    desktopEntry = {
      enable = true;
      name = "helium";
      displayName = "Helium";
      execArgs = "%U";
      icon = "web-browser";
      comment = "Navigateur web basé sur Chromium";
      categories = [ "Network" "WebBrowser" ];
      mimeTypes = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      actions = {
        "new-private-window" = {
          name = "Nouvelle fenêtre de navigation privée";
          execArgs = "--incognito %U";
        };
      };
    };
  };
}
