{ config, lib, plasma-manager, osConfig, ... }:

{
  imports = [
    plasma-manager.homeModules.plasma-manager
    ./plasma.nix
    ./panels.nix
    ./shortcuts.nix
  ];

  options.homeManager = {
    desktop.desktopEnvironment.plasma = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable KDE Plasma modules bundle.";
      };
    };
  };

  config =
    lib.mkIf
      (
        config.homeManager.desktop.desktopEnvironment.plasma.enable
        && osConfig.nixos.desktop.desktopEnvironment.plasma6.enable
      )
      {
        homeManager.desktop.desktopEnvironment.plasma = {
          plasma-default.enable = true;
          panels.enable = true;
          shortcuts.enable = true;
        };
      };
}