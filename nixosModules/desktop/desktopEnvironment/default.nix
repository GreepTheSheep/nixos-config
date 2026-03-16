{ lib, ... }:

{
  imports = [
    ./gnome.nix
    ./plasma6.nix
  ];

  options.nixos = {
    desktop.desktopEnvironment = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = false;
        description = "Enable desktopEnvironment modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.desktop.desktopEnvironment.enable {
    nixos.desktop.desktopEnvironment = {
      gnome.enable = lib.mkDefault false;
      plasma.enable = lib.mkDefault false;
    };
  };
}