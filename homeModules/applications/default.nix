{ config, lib, osConfig, ... }:

{
  imports = [
    ./browser
    ./communication
    ./development
    ./editing
    ./gaming
    ./media
    ./office
    ./screenshot
    ./sync
    ./terminal

    ./common.nix
    ./flatpak.nix
  ];

  options.homeManager = {
    applications = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable applications modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.enable {
    homeManager.applications = {
      browser.enable = true;
      communication.enable = true;
      development.enable = true;
      editing.enable = true;
      gaming.enable = lib.mkIf osConfig.nixos.userEnvironment.game.enable true;
      media.enable = true;
      office.enable = true;
      screenshot.enable = true;
      sync.enable = true;
      terminal.enable = lib.mkDefault false;

      common.enable = true;
      flatpak.enable = lib.mkDefault false;
    };
  };
}