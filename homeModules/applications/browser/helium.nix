{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.browser.helium = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = false;
        description = "Enable Helium browser.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.browser.helium.enable {
    home.packages = with pkgs; [
      nur.repos.lonerOrz.helium
    ];
  };
}
