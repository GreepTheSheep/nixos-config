{ config, lib, ... }:

{
  options.nixos = {
    userEnvironment.flatpak = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable system-level flatpak support.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.flatpak.enable {
    services.flatpak.enable = true;
  };
}
