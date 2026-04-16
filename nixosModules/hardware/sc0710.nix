# https://github.com/Nakildias/sc0710/issues/31

{ config, lib, pkgs, ... }:

let
  cfg = config.nixos.hardware.sc0710;

  # Compatible kernel versions (major.minor) — driver is broken on 7+
  # https://github.com/Nakildias/sc0710/blob/main/README.md
  compatibleKernels = [ "6.12" "6.13" "6.14" "6.15" "6.16" "6.17" "6.18" "6.19" ];

  currentKernelMajorMinor = lib.versions.majorMinor config.boot.kernelPackages.kernel.version;

  # Source from GitHub
  sc0710-src = pkgs.fetchFromGitHub {
    owner = "Nakildias";
    repo = "sc0710";
    rev = "main";
    sha256 = "sha256-aa4kVhS/fIPPy6zmrMViBUfmzLqWsiK6LU8WxStnWiU=";
  };

  # Driver kernel module
  sc0710 = pkgs.callPackage (
    { stdenv, fetchFromGitHub, kernel }:
    stdenv.mkDerivation rec {
      name = "sc0710-${version}-${kernel.version}";
      version = "2026.04.08-1";

      src = sc0710-src;

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

  # CLI script - fetched from GitHub
  sc0710-cli = pkgs.writeShellScriptBin "sc0710-cli" (builtins.readFile "${sc0710-src}/scripts/sc0710-cli.sh");

  # Firmware script - fetched from GitHub
  sc0710-firmware-script = pkgs.writeShellScript "sc0710-firmware" (builtins.readFile "${sc0710-src}/scripts/sc0710-firmware.sh");
in
{
  options.nixos.hardware.sc0710 = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable sc0710 support (Elgato 4K60 Pro MK.2 and 4K Pro drivers)";
    };

    enableFirmware = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable automatic firmware installation for Elgato 4K Pro (1cfa:0012)";
    };

    enableCLI = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "Install sc0710-cli control utility";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.elem currentKernelMajorMinor compatibleKernels;
        message = "sc0710 driver is not compatible with kernel ${currentKernelMajorMinor}. Compatible versions: ${lib.concatStringsSep ", " compatibleKernels}";
      }
    ];

    boot.extraModulePackages = [ sc0710 ];
    boot.kernelModules = [ "sc0710" ];

    environment.systemPackages = lib.mkIf cfg.enableCLI [ sc0710-cli ];

    systemd.services.sc0710-firmware = lib.mkIf cfg.enableFirmware {
      unitConfig = {
        Description = "Install SC0710 FPGA Firmware";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${sc0710-firmware-script}";
        RemainAfterExit = true;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}