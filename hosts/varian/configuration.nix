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

    nixos.hardware = {
      amdcpu.enable = false;
      nvidiagpu.enable = false;
    };

    nixos.system.user.defaultuser = {
      pass = ""; # TODO: remplir avec mkpasswd
    };

    nixos.virtualisation = {
      enable = true;
      docker.enable = true;
    };

    nixos.system.motd = {
      enable = true;
      content = builtins.readFile ./motd;
    };

    # Swap via zram uniquement (pas de swapfile sur microSD pour réduire l'usure)
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 100;
    };
  };
}
