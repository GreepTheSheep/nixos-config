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
      default = true;
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

    nixos.base = {
      caddy.enable = true;
      tools = {
        backrest.enable = true;
        scrutiny.enable = true;
      };
    };

    virtualisation.vmware.guest.enable = true;
    nixos.hardware = {
      amdcpu.enable = true;
      #sc0710.enable = true; # Elgato 4K60 Pro MK.2
    };

    nixos.system = {
      user.defaultuser = {
        pass = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
      };
    };

    nixos.userEnvironment = {
      enable = true;
      flatpak.enable = true;
    };
  };
}