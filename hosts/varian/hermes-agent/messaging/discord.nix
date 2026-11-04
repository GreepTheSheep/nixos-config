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
        DISCORD_HOME_CHANNEL = "1484999980442845294";
        DISCORD_ALLOW_BOTS = "mentions";
      };
      settings = {
        display.platforms.discord = {
          tool_progress = "off";
          interim_assistant_messages = false;
          long_running_notifications = false;
        };
        discord = {
          auto_thread = false;
          reactions = false;
          voice_channel_inactivity_timeout_seconds = 0;
          ignored_channels = [
            "596307060010778665"
            "563241725133455391"
            "626846666745577504"
            "562701687261888535"
            "1186632496054542357"
          ];
        };
      };
    };
  };
}
