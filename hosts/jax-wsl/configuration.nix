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
    imports = [
      # include NixOS-WSL modules
      nixos-wsl.nixosModules.wsl
      <nixos-wsl/modules>
    ];

    wsl = {
      enable = true;
      defaultUser = config.nixos.system.user.defaultuser.name;
    };

    nixos.desktop.enable = false;

    nixos.system = {
      user.defaultuser = {
        pass = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
      };
    };

    nixos.userEnvironment.enable = true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}