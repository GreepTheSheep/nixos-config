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
    host.containers.enable = false;

    #nixos.base.tools = {
    #  backrest = {
    #    enable = true;
    #    openFirewall = true;
    #  };
    #  scrutiny = {
    #    enable = true;
    #    openFirewall = true;
    #  };
    #};

    nixos.desktop.enable = false;

    nixos.hardware = {
      amdcpu.enable = true;
      nvidiagpu.enable = true;
    };

    nixos.system = {
      nixos.garbageCollect = true;
      secureboot.enable = true;

      user.defaultuser = {
        pass = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
      };

      motd = {
        enable = true;
        content = builtins.readFile ./motd;
      };
    };

    nixos.userEnvironment.enable = false;

    nixos.virtualisation = {
      enable = true;
      docker.enable = true;
    };
  };
}