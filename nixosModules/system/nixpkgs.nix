{ config, lib, ... }:

{
  options.nixos = {
    system.nixpkgs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable nixpkgs overrides.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.nixpkgs.enable {
    # Skips checks on openldap on i686 (does build failure recently, so we add this to skip)
    nixpkgs.overlays = [
      (_: prev: {
        openldap = prev.openldap.overrideAttrs {
          doCheck = !prev.stdenv.hostPlatform.isi686;
        };
      })
    ];
  };
}