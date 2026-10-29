{ config, lib, ... }:

{
  imports = [
    ./at.nix
    ./backrest.nix
    ./bitwarden.nix
    ./common.nix
    ./git.nix
    ./htop.nix
    ./java.nix
    ./scrutiny.nix
    ./usbtop.nix
  ];

  options.nixos = {
    base.tools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable tools modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.tools.enable {
    nixos.base.tools = {
      at.enable = true;
      backrest.enable = lib.mkDefault false;
      bitwarden.enable = true;
      common.enable = true;
      git.enable = true;
      htop.enable = true;
      java.enable = lib.mkDefault false;
      scrutiny.enable = lib.mkDefault false;
      usbtop.enable = true;
    };
  };
}
