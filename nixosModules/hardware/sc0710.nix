{ config, lib, pkgs, ... }:

let
  sc0710 = pkgs.callPackage (
    { stdenv, fetchFromGitHub, kernel }:
    stdenv.mkDerivation rec {
      name = "sc0710-${version}-${kernel.version}";
      version = "2026.03.21";

      src = fetchFromGitHub {
        owner = "Nakildias";
        repo = "sc0710";
        rev = "main";
        sha256 = "sha256-8dFfGaMkJfRdHU98P+qXcwb4lYh9fTtk6rFz5X7xjOg=";
      };

      nativeBuildInputs = [ kernel.moduleBuildDependencies ];

      makeFlags = [
        "KBUILD_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      ];

      installPhase = ''
        mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/media/pci/
        install -D build/sc0710.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/media/pci/
      '';
    }
  ) { kernel = config.boot.kernelPackages.kernel; };
in
{
  options.nixos = {
    hardware.sc0710 = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable sc0710 support. (Elgato 4K60 Pro MK.2 (1cfa:000e) and Elgato 4K Pro (1cfa:0012) drivers)";
      };
    };
  };

  config = lib.mkIf config.nixos.hardware.sc0710.enable {
    boot.extraModulePackages = [ sc0710 ];
    boot.kernelModules = [ "sc0710" ];
  };
}