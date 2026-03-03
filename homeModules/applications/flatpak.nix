{ config, lib, nix-flatpak, ... }:

{
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
  ];

  options.homeManager = {
    applications.flatpak = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable flatpak apps.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.flatpak.enable {
    services.flatpak = {
      enable = true;
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      packages = [
        "com.github.tchx84.Flatseal"
      ];
    };
  };
}