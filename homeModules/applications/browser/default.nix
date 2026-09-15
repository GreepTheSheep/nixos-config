{ config, lib, ... }:

{
  imports = [
    ./firefox.nix
    ./helium.nix
  ];

  options.homeManager = {
    applications.browser = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable browser modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.browser.enable {
    homeManager.applications.browser = {
      firefox.enable = true;
      helium.enable = true;
    };
  };
}
