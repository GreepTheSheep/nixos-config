{ config, lib, pkgs, ... }:

{
  options.nixos = {
    userEnvironment.common = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable common userEnvironment apps.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.common.enable {
    environment.defaultPackages = with pkgs; [
      wl-clipboard
      hardinfo2
      imagemagick
      junction
    ];
  };
}