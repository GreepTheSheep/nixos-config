{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.tangled-discord-bot-rust = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable tangled-discord-bot-rust container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/tangled-discord-bot-rust";
  in lib.mkIf config.host.containers.tangled-discord-bot-rust.enable {
    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${user} users"
      "d ${directory}/data 0755 ${user} users"
    ];

    sops.secrets = {
      "docker/tangled-discordbot-rust/discord-token" = {};
      "docker/tangled-discordbot-rust/owner-id"  = {};
      "docker/tangled-discordbot-rust/openai-key"  = {};
    };

    sops.templates = {
      "tangled-discordbot-rust.env".content = ''
        DISCORD_TOKEN=${config.sops.placeholder."docker/tangled-discordbot-rust/discord-token"}
        OWNER_ID=${config.sops.placeholder."docker/tangled-discordbot-rust/owner-id"}
        OPENAI_KEY=${config.sops.placeholder."docker/tangled-discordbot-rust/openai-key"}
      '';
    };

    virtualisation.oci-containers.containers.tangled-discordbot-rust = {
      image = "ghcr.io/greepthesheep/rust-tangled-discord-bot/rust-tangled-discordbot";
      environment = {
        TZ = "Europe/Paris";
        BOT_DISABLE_MUSIC_PLAYER = "1";
      };
      environmentFiles = [
        config.sops.templates."tangled-discordbot-rust.env".path
      ];
    };
  };
}