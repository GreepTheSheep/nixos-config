{ config, lib, ... }:

{
  imports = [
    ./bs-manager.nix
    ./dolphin-emu.nix
    ./lutris.nix
    ./nxapi.nix
    ./parallel-launcher.nix
    ./parsec.nix
    ./prismlauncher.nix
    ./sober.nix
    ./wheelwizard.nix
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
      bs-manager.enable = lib.mkDefault false;
      dolphin-emu.enable = lib.mkDefault false;
      lutris.enable = lib.mkDefault false;
      nxapi.enable = lib.mkDefault false;
      parallelLauncher.enable = true;
      parsec.enable = true;
      prismlauncher.enable = true;
      sober.enable = lib.mkIf config.homeManager.applications.flatpak.enable true;
      wheelwizard.enable = lib.mkDefault false;
    };
  };
}
