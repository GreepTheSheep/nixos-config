{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.utils.bottles = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Bottles.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.utils.bottles.enable {
    home.packages = with pkgs; [
      (bottles.override {
        removeWarningPopup = true;
      })
    ];
  };
}
