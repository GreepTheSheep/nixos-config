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
    virtualisation.vmware.guest.enable = true;

    nixos.desktop.enable = false;

    nixos.hardware = {
      amdcpu.enable = true;
    };

    nixos.system.user.defaultuser = {
      pass = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
    };

    nixos.userEnvironment.enable = false;

    nixos.virtualisation = {
      enable = true;
      docker.enable = true;
    };

    nixos.system.motd = {
      enable = true;
    };
  };
}