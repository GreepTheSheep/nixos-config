{ config, lib, ... }:

{
  imports = [
    ./bind.nix
    ./cloudflared.nix
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
      bind.enable = lib.mkDefault false;
      cloudflared.enable = lib.mkDefault false;
      ollama.enable = lib.mkDefault false;
      samba.enable = lib.mkDefault false;
    };
  };
}