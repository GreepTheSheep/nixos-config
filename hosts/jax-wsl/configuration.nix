{ config, lib, pkgs, nixos-wsl, ... }:

{
  imports = [
    # include NixOS-WSL modules
    nixos-wsl.nixosModules.wsl
  ];

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
    wsl = {
      enable = true;
      defaultUser = config.nixos.system.user.defaultuser.name;
    };

    # Disable rules that are not necessary on WSL
    nixos = {
      desktop.enable = false;
      base.shell.console.enable = lib.mkForce false;
      system = {
        powermanagement.enable = lib.mkForce false;
        bootloader.enable = lib.mkForce false;
        networking.enable = lib.mkForce false;
        motd = {
          enable = true;
          content = builtins.readFile ./motd;
        };
        user.defaultuser = {
          pass = "$6$wpoCAeUVymh0/wJ8$.T2bnLYhQXc8ReqvbPVaH89g9cVeHuQVKHaBTCgTdH0xP6oAdMNWs7R5vkatJClJYbfG1u9EnXr8ELv2fPC.3/";
        };
      };
      userEnvironment = {
        enable = true;
        non-nix-apps = {
          affine.enable = lib.mkForce false;
          feishin.enable = lib.mkForce false;
        };
      };
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}