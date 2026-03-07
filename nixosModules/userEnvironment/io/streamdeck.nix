{ config, lib, ... }:

{
  options.nixos = {
    userEnvironment.io.streamdeck = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Stream Deck Controller.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.io.streamdeck.enable {
    programs.streamcontroller.enable = true;
  };
}