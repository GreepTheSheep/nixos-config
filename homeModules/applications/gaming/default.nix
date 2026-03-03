{ config, lib, ... }:

{
  imports = [
    ./lutris.nix
    ./parsec.nix
    ./prismlauncher.nix
  ];

  options.homeManager = {
    applications.gaming = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable gaming modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.gaming.enable {
    homeManager.applications.gaming = {
      lutris.enable = true;
      parsec.enable = true;
      prismlauncher.enable = true;
    };
  };
}