{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.utils.rpi-imager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable RPI Imager.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.utils.rpi-imager.enable {
    home.packages = with pkgs; [
      rpi-imager
    ];
  };
}
