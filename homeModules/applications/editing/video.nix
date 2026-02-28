{ config, lib, pkgs, ... }:

{
  options.homeManager = {
    applications.editing.video = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable video tools.";
      };

      enableDavinciResolve = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable DaVinci Resolve.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.editing.video.enable {
    home.packages = with pkgs; [
      kdePackages.kdenlive
      #glaxnimate
    ] ++ lib.optionals (config.homeManager.applications.editing.video.enableDavinciResolve) [
      davinci-resolve
    ];
  };
}