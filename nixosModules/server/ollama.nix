{ config, lib, ... }:

{
  options.nixos = {
    server.ollama = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable ollama.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Open firewall for ollama.";
      };

      accel = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            false
            "rocm"
            "cuda"
            "vulkan"
          ]
        );
        default = null;
        example = "cuda";
        description = "Enable GPU accel. null or one of false, 'rocm', 'cuda', 'vulkan'";
      };

      downloadModels = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "gemma4:latest" ];
        description = "Download models";
      };
    };
  };

  config = lib.mkIf config.nixos.server.ollama.enable {
    services.ollama = {
      enable = true;
      openFirewall = config.nixos.server.ollama.openFirewall;
      loadModels = config.nixos.server.ollama.downloadModels;
      host = lib.mkIf config.nixos.server.ollama.openFirewall "0.0.0.0";
      port = 11434;
    };
  };
}