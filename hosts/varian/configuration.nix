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

    nixpkgs = lib.mkOption {
      type = lib.types.enum [
        "stable"
        "unstable"
      ];
      default = "stable";
      description = "Nixpkgs channel to use for this host.";
    };
  };

  config = {
    host.nixpkgs = "unstable";

    nixos = {
      system = {
        bootloader.enable = lib.mkForce false; # Do not use Limine, keep using generic RPI bootloader
        nixos.garbageCollect = true;

        user.defaultuser = {
          pass = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
        };

        motd = {
          enable = true;
          content = builtins.readFile ./motd;
        };
      };

      desktop.enable = false;
      userEnvironment.hermes-agent.enable = true;

      virtualisation = {
        enable = true;
        docker.enable = true;
      };
    };
  };
}
