{ config, lib, ... }:

{
  options.host = {
    hermes-agent.messaging.discord = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Hermes Agent to Discord";
      };
    };
  };

  config = lib.mkIf config.host.hermes-agent.messaging.discord.enable {

    sops = {
      secrets = {
        "hermes/discord-bot-token" = { };
      };
      templates."hermes-discord.env".content = ''
        DISCORD_BOT_TOKEN=${config.sops.placeholder."hermes/discord-bot-token"}
      '';
    };

    services.hermes-agent = {
      environmentFiles = lib.mkAfter [
        config.sops.templates."hermes-discord.env".path
      ];
      environment = {
        DISCORD_ALLOW_ALL_USERS = "true"; # Act like a chatbot for everyone on guilds
        DISCORD_REACTIONS = "false";
        DISCORD_ALLOW_MENTION_ROLES = "true";
      };
    };
  };
}
