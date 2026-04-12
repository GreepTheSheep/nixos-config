{ config, lib, inputs, pkgs, ... }:

{
  options.homeManager = {
    applications.development.opencode = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable OpenCode.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.development.opencode.enable {
    programs.opencode = {
      enable = true;
    };
  };
}