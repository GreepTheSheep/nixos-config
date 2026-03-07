{ config, lib, ... }:

{
  imports = [
    ./streamdeck.nix
  ];

  options.homeManager = {
    applications.utils = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable terminal modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.utils.enable {
    homeManager.applications.utils = {
      streamdeck.enable = lib.mkDefault false;
    };
  };
}