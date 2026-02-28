{ config, lib, ... }:

{
  options.homeManager = {
    applications.communication.element = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Element Desktop.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.communication.element.enable {
    programs.element-desktop = {
      enable = true;
    };
  };
}