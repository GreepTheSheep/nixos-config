{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.development.filezilla = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable FileZilla.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.development.filezilla.enable {
    home.packages = with pkgs; [
      filezilla
    ];
  };
}