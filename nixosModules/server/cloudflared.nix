{ config, lib, ... }:

{
  options.nixos = {
    server.cloudflared = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable cloudflared.";
      };
    };
  };

  config = lib.mkIf config.nixos.server.cloudflared.enable {
    services.cloudflared = {
      enable = true;
    };
  };
}