{ config, lib, ... }:

{
  imports = [
    ./ollama.nix
    ./samba.nix
  ];

  options.nixos = {
    server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable server modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.server.enable {
    nixos.server = {
      ollama.enable = lib.mkDefault false;
      samba.enable = lib.mkDefault false;
    };
  };
}