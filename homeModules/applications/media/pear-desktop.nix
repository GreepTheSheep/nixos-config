{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.media.pear-desktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Pear desktop (Youtube Music).";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.media.pear-desktop.enable {
    home.packages = with pkgs; [
      pear-desktop
    ];
  };
}
