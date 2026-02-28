{ config, lib, ... }:

{
  imports = [
    ./audio.nix
    ./compiler.nix
    ./image.nix
    ./video.nix
  ];

  options.homeManager = {
    applications.editing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable editing modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.editing.enable {
    homeManager.applications.editing = {
      audio.enable = true;
      compiler.enable = true;
      image.enable = true;
      video.enable = true;
    };
  };
}