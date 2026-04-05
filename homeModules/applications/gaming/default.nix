{ config, lib, ... }:

{
  imports = [
    ./bs-manager.nix
    ./lutris.nix
    ./parsec.nix
    ./prismlauncher.nix
    ./sober.nix
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
      bs-manager.enable = true;
      lutris.enable = true;
      parsec.enable = true;
      prismlauncher.enable = true;
      sober.enable = lib.mkIf config.homeManager.applications.flatpak.enable true;
    };
  };
}