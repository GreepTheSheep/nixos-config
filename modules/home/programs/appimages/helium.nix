{ config, lib, ... }:

{
  appimages.apps.helium = {
    enable = true;
    
    # Télécharge automatiquement la dernière version depuis GitHub
    githubRepo = "imputnet/helium-linux";
    githubAssetPattern = "x86_64.AppImage";
    
    filename = "helium.AppImage";
    autoUpdate = false;
  };
}
