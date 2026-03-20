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
    nixos.system.nixos.garbageCollect = true;

    nixos.desktop.enable = false;
    nixos.userEnvironment.enable = false;

    nixos.system.user.defaultuser = {
      pass = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
    };

    nixos.virtualisation = {
      enable = true;
      docker.enable = true;
    };

    nixos.system.motd = {
      enable = true;
      content = builtins.readFile ./motd;
    };
  };
}
