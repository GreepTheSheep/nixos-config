{ config, lib, ... }:

{
  options.host = {
    containers.wud = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable What's up Docker container for this host";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/wud";
  in lib.mkIf config.host.containers.wud.enable {
    systemd.tmpfiles.rules = [
      "d ${directory} 0755 ${user} users"
      "d ${directory}/data 0755 ${user} users"
    ];

    sops.secrets ={
      "docker/wud/auth-hash" = {};
      "gitea/registry-password" = {};
      "docker/wud/vigor-notification-url" = {};
    };

    sops.templates."wud.env".content = ''
      WUD_AUTH_BASIC_GREEP_USER=greep
      WUD_AUTH_BASIC_GREEP_HASH='${config.sops.placeholder."docker/wud/auth-hash"}'
      WUD_REGISTRY_GITEA_GREEP_URL=https://git.greep.fr
      WUD_REGISTRY_GITEA_GREEP_LOGIN=greep
      WUD_REGISTRY_GITEA_GREEP_PASSWORD=${config.sops.placeholder."gitea/registry-password"}
      WUD_WATCHER_LOCAL_CRON=0 0 6 * * *
      WUD_TRIGGER_DISCORD_1_URL=${config.sops.placeholder."docker/wud/vigor-notification-url"}
      WUD_TRIGGER_DISCORD_1_BOTUSERNAME=WUD @ vigor.greep.fr
    '';

    virtualisation.oci-containers.containers.wud = {
      image = "ghcr.io/getwud/wud";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "${directory}/data:/store"
      ];
      environment = {
        TZ = "Europe/Paris";
      };
      environmentFiles = [
        config.sops.templates."wud.env".path
      ];
      ports = [
        "3000:3000"
      ];
    };
  };
}