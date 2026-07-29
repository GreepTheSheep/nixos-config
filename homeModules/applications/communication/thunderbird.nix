{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.communication.thunderbird = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Thunderbird.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.communication.thunderbird.enable {
    programs.thunderbird = {
      enable = true;
    };
  };
}