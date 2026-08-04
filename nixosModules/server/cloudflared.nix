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
    sops.secrets = {
      "cloudflared/certificate" = {};
    };

    sops.templates = {
      "cert.pem".content = ''
        -----BEGIN ARGO TUNNEL TOKEN-----
        ${config.sops.placeholder."cloudflared/certificate"}
        -----END ARGO TUNNEL TOKEN-----
      '';
    };

    services.cloudflared = {
      enable = true;
      certificateFile = config.sops.templates."cert.pem".path;
    };
  };
}