{ lib, pkgs, ... }:

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
      xrdp.enable = true;
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

    nixos.base = {
      caddy.enable = true;
      tools = {
        backrest.enable = true;
        scrutiny.enable = true;
      };
    };

    nixos.hardware = {
      amdcpu.enable = true;
      nvidiagpu.enable = true;
      sc0710.enable = true; # Elgato 4K60 Pro MK.2
    };

    nixos.system = {
      boot.kernel = pkgs.linuxPackages_zen;
      secureboot.enable = true;
      nixosvm = {
        enable = true;
        memorySize = 24576;
      };

      user.defaultuser = {
        pass = "$y$j9T$Gmd5se3DKJe4508IpvpNK.$Yq2XI4JqqbBrBIOSfjlWHYcKx.Po.ZEkqcKYm7LEtx/";
      };
    };

    nixos.userEnvironment = {
      enable = true;
      flatpak.enable = true;
      game = {
        enable = true;
        vr = {
          enable = true;
          enableWiVRn = true;
        };
      };
      io = {
        streamdeck.enable = true;
        bluetooth.enable = true;
      };
    };

    nixos.server = {
      ollama = {
        enable = true;
        openFirewall = true;
        accel = "cuda";
      };
    };

    nixos.virtualisation = {
      enable = true;
      android.enable = true;
      docker.enable = true;
      vmware.enable = true;
      kvm.enable = true;
      waydroid.enable = true;
    };

    nixos.pkgs.wallpaper-engine-kde-plugin.enable = true;

    nixos.system.cloudmount.enable = true;
    sops.age.keyFile = "/root/.secrets/keys.txt";

    systemd.tpm2.enable = true;
  };
}