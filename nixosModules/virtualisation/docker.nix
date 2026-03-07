{ config, lib, pkgs, ... }:

{
  options = {
    nixos.virtualisation.docker = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Docker virtualisation.";
      };
    };
  };

  config = lib.mkIf config.nixos.virtualisation.docker.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      extraPackages = with pkgs; [
        lazydocker
        oxker
      ];
    };

    hardware.nvidia-container-toolkit.enable = lib.mkIf (
      config.nixos.hardware.nvidiagpu.enable && config.nixos.virtualisation.docker.enable
    ) true;

    users.users."${config.nixos.system.user.defaultuser.name}" = {
      extraGroups = [
        "docker"
      ];
    };

    environment.systemPackages = with pkgs; lib.mkAfter [
      lazydocker
      oxker
    ];
  };
}