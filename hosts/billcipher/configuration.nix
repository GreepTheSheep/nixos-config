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

    nixpkgs = lib.mkOption {
      type = lib.types.enum [ "stable" "unstable" ];
      default = "stable";
      description = "Nixpkgs channel to use for this host.";
    };
  };

  config = {

    host.containers.enable = true;

    nixos.desktop.enable = false;

    nixos.hardware.intelcpu.enable = true;

    nixos.system = {
      bootloader.timeout = 1;
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