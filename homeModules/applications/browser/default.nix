{ config, lib, ... }:

{
  imports = [
    ./firefox.nix
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
      # Helium is managed on system config: Home Manager can't manage tarballs
    };
  };
}