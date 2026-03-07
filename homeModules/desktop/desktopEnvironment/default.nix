{ config, lib, osConfig, ... }:

{
  imports = [
    ./gnome
    ./plasma
  ];

  options.homeManager = {
    desktop.desktopEnvironment = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable desktopEnvironment modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.desktop.desktopEnvironment.enable {
    homeManager.desktop.desktopEnvironment = {
      gnome.enable = lib.mkIf osConfig.nixos.desktop.desktopEnvironment.gnome.enable true;
      plasma.enable = lib.mkIf osConfig.nixos.desktop.desktopEnvironment.plasma6.enable true;
    };
  };
}