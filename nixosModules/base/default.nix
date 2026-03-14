{ config, lib, ... }:

{
  imports = [
    ./shell
    ./texteditor
    ./tools

    ./caddy.nix
  ];

  options.nixos = {
    base = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable base modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.enable {
    nixos.base = {
      shell.enable = true;
      texteditor.enable = true;
      tools.enable = true;
      caddy.enable = true;
    };
  };
}