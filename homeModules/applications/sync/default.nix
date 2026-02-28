{ config, lib, ... }:

{
  imports = [
    ./barrier.nix
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
      barrier.enable = lib.mkDefault false;
      kdeconnect.enable = true;
      rclone.enable = lib.mkDefault false;
    };
  };
}