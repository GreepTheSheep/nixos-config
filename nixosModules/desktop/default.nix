{ config, lib, ... }:

{
  imports = [
    ./desktopEnvironment
    ./displayManager
    ./windowManager
    ./xdg.nix
    ./xrdp.nix
    ./xserver.nix
  ];

  options.nixos = {
    desktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable desktop modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.desktop.enable {
    nixos.desktop = {
      desktopEnvironment.enable = true;
      displayManager.enable = true;
      windowManager.enable = true;
      xdg.enable = true;
      xrdp.enable = true;
      xserver.enable = true;
    };
  };
}