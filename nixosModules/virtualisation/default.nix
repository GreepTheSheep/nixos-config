{ config, lib, ... }:

{
  imports = [
    ./android.nix
    ./docker.nix
    ./kvm.nix
    ./vmware.nix
    ./waydroid.nix
  ];

  options.nixos = {
    virtualisation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable virtualisation modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.virtualisation.enable {
    nixos.virtualisation = {
      android.enable = lib.mkDefault false;
      docker.enable = lib.mkDefault false;
      kvm.enable = lib.mkDefault false;
      vmware.enable = lib.mkDefault false;
      waydroid.enable = lib.mkDefault false;
    };
  };
}