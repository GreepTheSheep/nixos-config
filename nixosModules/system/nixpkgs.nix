{ config, lib, inputs, ... }:

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
    nixpkgs = {
      # Skips checks on openldap on i686 (does build failure recently, so we add this to skip)
      # + overlay local nxapi packages (pkgs.nxapi, pkgs.nxapi-electron)
      overlays = [
        (_: prev: {
          openldap = prev.openldap.overrideAttrs {
            doCheck = !prev.stdenv.hostPlatform.isi686;
          };
        })
        inputs.self.overlays.default
      ];

      # Allow Electron 39.8.10 to build. Required for Bitwarden Desktop on NixOS 26.05
      config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };
  };
}