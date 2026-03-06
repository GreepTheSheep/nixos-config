{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.sync.deskflow = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable deskflow sync.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.sync.deskflow.enable {
    home.packages = with pkgs; [
      deskflow
    ];
  };
}