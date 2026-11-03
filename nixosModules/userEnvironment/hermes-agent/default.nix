{
  config,
  lib,
  hermes-agent,
  ...
}:

{
  imports = [
    hermes-agent.nixosModules.default
  ];

  options.nixos.userEnvironment.hermes-agent = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable Hermes Agent";
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.hermes-agent.enable {
    sops = {
      secrets = {
        "hermes/ollama-api-key" = { };
      };
      templates."hermes.env".content = ''
        OLLAMA_API_KEY=${config.sops.placeholder."hermes/ollama-api-key"}
      '';
    };

    services.hermes-agent = {
      enable = true;
      container.enable = config.nixos.virtualisation.docker.enable;
      settings = {
        model.default = "deepseek-v4.1-flash:1017"; # Default Ollama model used from Ollama Cloud
        toolsets = [ "all" ];
      };
      environmentFiles = [ config.sops.templates."hermes.env".path ];
      addToSystemPackages = true;
    };
  };
}
