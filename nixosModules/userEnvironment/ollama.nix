{ config, lib, ... }:

{
  options.nixos = {
    userEnvironment.ollama = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable ollama.";
      };

      enableUI = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable frontend UI.";
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
        type = lib.types.listOf types.str;
        default = [ ];
        example = [ "quen3.5" ];
        description = "Download models";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.ollama.enable {
    services.ollama = {
      # Port 11434
      enable = true;
      openFirewall = config.nixos.userEnvironment.ollama.openFirewall;
      loadModels = config.nixos.userEnvironment.ollama.downloadModels;
      host = lib.mkIf config.nixos.userEnvironment.ollama.openFirewall "0.0.0.0";
    };

    services.nextjs-ollama-llm-ui.enable = config.nixos.userEnvironment.ollama.enableUI;
  };
}