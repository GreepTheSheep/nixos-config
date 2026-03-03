{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.office.obsidian = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Obsidian.md.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.office.obsidian.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}