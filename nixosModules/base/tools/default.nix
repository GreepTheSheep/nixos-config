{ config, lib, ... }:

{
  imports = [
    ./backrest.nix
    ./common.nix
    ./git.nix
    ./htop.nix
    ./java.nix
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
      backrest.enable = true;
      common.enable = true;
      git.enable = true;
      htop.enable = true;
      java.enable = lib.mkDefault false;
      usbtop.enable = true;
    };
  };
}