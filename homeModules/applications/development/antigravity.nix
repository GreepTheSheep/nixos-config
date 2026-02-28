{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.development.antigravity = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Google Antigravity IDE.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.development.antigravity.enable {
    home.packages = with pkgs; [
      antigravity
    ];
  };
}