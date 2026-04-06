{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.tangled-discord-bot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable tangled-discord-bot container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/tangled-discord-bot";
  in lib.mkIf config.host.containers.tangled-discord-bot.enable {
    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${user} users"
      "d ${directory}/data 0755 ${user} users"
    ];

    sops.secrets = {
      "docker/tangled-discordbot/discord-token" = {};
      "docker/tangled-discordbot/owner-id"  = {};
      "docker/tangled-discordbot/openai-key"  = {};
    };

    sops.templates = {
      "tangled-discordbot.env".content = ''
        DISCORD_TOKEN=${config.sops.placeholder."docker/tangled-discordbot/discord-token"}
        OWNER_ID=${config.sops.placeholder."docker/tangled-discordbot/owner-id"}
        OPENAI_KEY=${config.sops.placeholder."docker/tangled-discordbot/openai-key"}
      '';
    };

    virtualisation.oci-containers.containers.tangled-discordbot = {
      image = "ghcr.io/greepthesheep/tangled-discord-bot/tangled-discordbot";
      volumes = [
        "${directory}/data:/home/node/app/data"
      ];
      environment = {
        TZ = "Europe/Paris";
        NODE_ENV = "production";
        BOT_DISABLE_MUSIC_PLAYER = "1";
      };
      environmentFiles = [
        config.sops.templates."tangled-discordbot.env".path
      ];
    };
  };
}