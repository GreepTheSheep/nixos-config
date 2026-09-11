{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.gaming.wheelwizard = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Wheel Wizard.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.gaming.wheelwizard.enable {
    home.packages = with pkgs; [
      wheelwizard
    ];
  };
}
