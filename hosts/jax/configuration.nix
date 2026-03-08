{ lib, ... }:

{
  options.host = {
    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is the host a laptop ?";
    };

    isVM = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is the host a VM ?";
    };

    isLiveIso = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is the host a Live ISO ?";
    };
  };

config = {
    nixos.desktop = {
      enable = true;
      desktopEnvironment = {
        plasma6.enable = true;
      };
      displayManager = {
        defaultSession = "plasma";
        sddm.enable = true;
      };
      windowManager = {
        hyprland.enable = false;
      };
    };

    nixos.hardware = {
      amdcpu.enable = true;
      nvidiagpu.enable = true;
    };

    nixos.system.user.defaultuser = {
      pass = "$y$j9T$Gmd5se3DKJe4508IpvpNK.$Yq2XI4JqqbBrBIOSfjlWHYcKx.Po.ZEkqcKYm7LEtx/";
    };

    nixos.system.secureboot.enable = true;

    nixos.userEnvironment = {
      enable = true;
      flatpak.enable = true;
      game.enable = true;
      io = {
        streamdeck.enable = true;
        bluetooth.enable = true;
      };
    };

    nixos.virtualisation = {
      enable = true;
      docker.enable = true;
      vmware.enable = true;
      waydroid.enable = true;
    };

    nixos.pkgs.wallpaper-engine-kde-plugin.enable = true;

    nixos.system.cloudmount.enable = true;
    sops.age.keyFile = "/root/.secrets/keys.txt";
  };
}