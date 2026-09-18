{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homeManager = {
    applications.browser.chromium = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = false;
        description = "Enable Chromium browser.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.ungoogled-chromium;
        example = pkgs.chromium;
        description = "Chromium package to use.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.browser.chromium.enable {
    programs.chromium = {
      enable = true;
      package = config.homeManager.applications.browser.chromium.package;
    };
  };
}
