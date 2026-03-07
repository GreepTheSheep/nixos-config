{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.utils.streamdeck = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Stream Deck Controller.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.utils.streamdeck.enable {
    home.packages = with pkgs; [
      streamcontroller
    ];
  };
}