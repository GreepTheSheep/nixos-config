{ config, lib, ... }:

{
  imports = [
    #./obs-studio.nix
  ];

  options.nixos = {
    userEnvironment.config = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable config modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.config.enable {
    nixos.userEnvironment.config = {
      #obs-studio.enable = true;
    };
  };
}