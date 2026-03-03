{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.development.github-desktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Github Desktop.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.development.github-desktop.enable {
    home.packages = with pkgs; [
      github-desktop
    ];
  };
}