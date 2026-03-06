{ config, lib, ... }:

{
  imports = [
    ./deskflow.nix
    ./kdeconnect.nix
    ./rclone.nix
  ];

  options.homeManager = {
    applications.sync = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable sync modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.sync.enable {
    homeManager.applications.sync = {
      deskflow.enable = lib.mkDefault false;
      kdeconnect.enable = true;
      rclone.enable = lib.mkDefault false;
    };
  };
}