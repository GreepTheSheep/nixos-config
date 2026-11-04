{
  config,
  lib,
  pkgs,
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
        "hermes/dashboard-basic-auth-password" = { };
        "hermes/dashboard-basic-auth-secret" = { };
      };
      templates."hermes.env".content = ''
        OLLAMA_API_KEY=${config.sops.placeholder."hermes/ollama-api-key"}
        HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=${
          config.sops.placeholder."hermes/dashboard-basic-auth-password"
        }
        HERMES_DASHBOARD_BASIC_AUTH_SECRET=${config.sops.placeholder."hermes/dashboard-basic-auth-secret"}
      '';
    };

    services.hermes-agent = {
      enable = true;
      container = lib.mkIf config.nixos.virtualisation.docker.enable {
        enable = true;
        hostUsers = [ config.nixos.system.user.defaultuser.name ];
      };
      settings = {
        model.default = "deepseek-v4.1-flash:1017"; # Default Ollama model used from Ollama Cloud
        toolsets = [ "all" ];
        network.force_ipv4 = true;
      };
      environment = {
        HERMES_DASHBOARD_BASIC_AUTH_USERNAME = config.nixos.system.user.defaultuser.name;
      };
      environmentFiles = [ config.sops.templates."hermes.env".path ];
      addToSystemPackages = true;
    };

    # Restart the gateway when its configuration changes. Without this, a
    # `nixos-rebuild switch` rewrites config.yaml/.env but leaves the running
    # process on the old configuration.
    systemd.services.hermes-agent.restartTriggers = [
      (pkgs.writeText "hermes-agent-config" (
        builtins.toJSON {
          settings = config.services.hermes-agent.settings;
          environment = config.services.hermes-agent.environment;
          envTemplate = config.sops.templates."hermes.env".content;
        }
      ))
    ];

    users.users."hermes" = lib.mkIf config.nixos.virtualisation.docker.enable {
      extraGroups = [
        "docker"
      ];
    };

    security.sudo.extraRules = lib.mkIf config.nixos.virtualisation.docker.enable [
      {
        users = [ "hermes" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/docker";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
