{ config, lib, ... }:

{
  imports = [
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
    };
  };
}