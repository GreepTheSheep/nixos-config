{ config, lib, nix-flatpak, ... }:

{
  options.homeManager = {
    applications.gaming.sober = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Sober.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.gaming.sober.enable {
    services.flatpak.packages = [
      "org.vinegarhq.Sober"
    ];
  };
}