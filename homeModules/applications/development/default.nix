{ config, lib, osConfig, ... }:

{
  imports = [
    ./antigravity.nix
    ./bottles.nix
    ./claudecode.nix
    ./diff.nix
    ./filezilla.nix
    ./github-desktop.nix
    ./nixd.nix
    ./opencode.nix
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
      claudecode.enable = lib.mkDefault false;
      diff.enable = lib.mkDefault false;
      filezilla.enable = true;
      github-desktop.enable = lib.mkIf config.homeManager.applications.flatpak.enable true;
      nixd.enable = true;
      opencode.enable = lib.mkDefault false;
      virtualisation.enable = lib.mkIf osConfig.nixos.virtualisation.kvm.enable true;
      vscode.enable = true;
    };
  };
}