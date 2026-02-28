{ config, lib, osConfig, ... }:

{
  imports = [
    ./antigravity.nix
    ./bottles.nix
    ./claudecode.nix
    ./diff.nix
    ./nixd.nix
    ./virtualisation.nix
    ./vscode.nix
  ];

  options.homeManager = {
    applications.development = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable development modules bundle.";
      };
    };
  };

  config = lib.mkIf config.homeManager.applications.development.enable {
    homeManager.applications.development = {
      antigravity.enable = lib.mkDefault false;
      bottles.enable = true;
      diff.enable = lib.mkDefault false;
      claudecode.enable = lib.mkDefault false;
      nixd.enable = true;
      virtualisation.enable = lib.mkIf osConfig.nixos.virtualisation.kvm.enable true;
      vscode.enable = true;
    };
  };
}