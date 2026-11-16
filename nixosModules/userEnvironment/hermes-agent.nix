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
        "hermes/n8n-mcp-token" = { };
        "hermes/gitea-access-token" = { };
      };
      templates."hermes.env".content = ''
        OLLAMA_API_KEY=${config.sops.placeholder."hermes/ollama-api-key"}
        HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=${
          config.sops.placeholder."hermes/dashboard-basic-auth-password"
        }
        HERMES_DASHBOARD_BASIC_AUTH_SECRET=${config.sops.placeholder."hermes/dashboard-basic-auth-secret"}
        N8N_MCP_TOKEN=${config.sops.placeholder."hermes/n8n-mcp-token"}
        GITEA_ACCESS_TOKEN=${config.sops.placeholder."hermes/gitea-access-token"}
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
        plugins.enabled = [
          "web-ollama-cloud"
          "discord-chatlog"
          "discord-status"
        ];
        web = {
          backend = "ollama-cloud";
          search_backend = "ollama-cloud";
          extract_backend = "ollama-cloud";
        };
        network.force_ipv4 = true;
        # The `hermes` wrapper only appends its own runtime deps to PATH (node,
        # ripgrep, ffmpeg, git…), so `bw` never resolves inside the container and
        # the Bitwarden credential-vault backend stays disabled. Point it at the
        # store path: /nix/store is mounted read-only in the container.
        vault.bitwarden.binary_path = "${pkgs.bitwarden-cli}/bin/bw";
        mcp_servers = {
          gitea = {
            command = "node";
            args = [ "/data/.hermes/mcp/gitea-mcp/node_modules/gitea-mcp/dist/stdio.js" ];
            env = {
              GITEA_HOST = "https://git.greep.fr";
              GITEA_ACCESS_TOKEN = "\${GITEA_ACCESS_TOKEN}";
            };
            connect_timeout = 60;
          };
          context7 = {
            url = "https://mcp.context7.com/mcp";
            connect_timeout = 30;
          };
          cloudflare = {
            url = "https://mcp.cloudflare.com/mcp?codemode=false";
            auth = "oauth";
            oauth.redirect_port = 8912;
            connect_timeout = 60;
          };
          globalping = {
            url = "https://mcp.globalping.dev/mcp";
            auth = "oauth";
            oauth.redirect_port = 8913;
            connect_timeout = 60;
            tools.exclude = [
              "help"
              "compareLocations"
              "limits"
            ];
          };
          n8n = {
            url = "https://n8n.greep.fr/mcp-server/http";
            headers.Authorization = "Bearer \${N8N_MCP_TOKEN}";
            timeout = 300;
            connect_timeout = 60;
          };
          n8n-doc = {
            command = "node";
            args = [ "/data/.hermes/mcp/n8n-mcp/node_modules/n8n-mcp/dist/mcp/index.js" ];
            env = {
              MCP_MODE = "stdio";
              LOG_LEVEL = "error";
              DISABLE_CONSOLE_OUTPUT = "true";
            };
            lazy = true;
            connect_timeout = 60;
          };
        };
      };
      environment = {
        HERMES_DASHBOARD_BASIC_AUTH_USERNAME = config.nixos.system.user.defaultuser.name;
        # The container's $HOME is <stateDir>/home while the host user's $HOME is
        # <stateDir> itself, so a `bw login` run from a host shell writes a CLI
        # state the gateway never reads (and the session looks missing, not
        # expired). Pin the appdata dir to the shared state dir — container path,
        # /data is stateDir — so one login state serves both sides.
        BITWARDENCLI_APPDATA_DIR = "/data/.config/Bitwarden CLI";
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

    users.users."hermes" = {
      extraGroups = lib.optionals config.nixos.virtualisation.docker.enable [
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
