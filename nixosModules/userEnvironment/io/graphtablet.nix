{ config, lib, pkgs, ... }:

{
  options.nixos = {
    userEnvironment.io.graphtablet = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Graphical Tablet support (DIGImend and OpenTabletDriver).";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.io.graphtablet.enable {
    services.xserver = {
      digimend.enable = true;
      wacom.enable = true;
    };

    environment.systemPackages = [
      config.boot.kernelPackages.digimend
    ];

    hardware = {
      opentabletdriver.enable = true;
      uinput.enable = true; # Required by OpenTabletDriver
    };

    boot.kernelModules = [ "uinput" ]; # Required by OpenTabletDriver

    programs.xppen.enable = true;
  };
}