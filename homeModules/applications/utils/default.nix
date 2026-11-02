{ config, lib, ... }:

{
  imports = [
    ./bottles.nix
    ./rpi-imager.nix
  ];

  options.homeManager = {
    applications.utils = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable utils bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.utils.enable {
    homeManager.applications.utils = {
      bottles.enable = true;
      rpi-imager.enable = lib.mkDefault false;
    };
  };
}
