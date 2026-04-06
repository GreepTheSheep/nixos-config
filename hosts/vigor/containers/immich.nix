{ config, lib, pkgs, ... }:

{
  options.host = {
    containers.immich = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Immich container for this host";
      };

      enableGPU = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable GPU for the Immich container";
      };
    };
  };

  config =
  let
    user = config.nixos.system.user.defaultuser.name;
    home = config.users.users."${user}".home;
    directory = "${home}/docker-containers/immich";
    caddySiteDirectory = "${home}/docker-containers/caddy/sites";

    dataDirectory = "/mnt/data/immich-lib";
  in lib.mkIf config.host.containers.jellyfin.enable {
    systemd.tmpfiles.rules = lib.mkMerge [
      ([
        "d ${directory} 0755 ${user} users"
        "d ${directory}/ml-model-cache 0755 ${user} users"
        "d ${directory}/pgdata 0755 ${user} users"
      ])
      (lib.mkIf config.host.containers.caddy.enable [
        "C+ ${caddySiteDirectory}/immich.caddy 0755 ${config.nixos.system.user.defaultuser.name} users - ${pkgs.writeText "immich.caddy" ''
          immich.greep.fr {
            reverse_proxy immich:2283
          }
        ''}"
      ])
    ];

    sops.secrets = {
      "docker/immich/postgres-password" = {};
      "docker/immich/postgres-database" = {};
      "docker/immich/postgres-user" = {};
    };

    sops.templates = {
      "immich.env".content = ''
        DB_PASSWORD=${config.sops.placeholder."docker/immich/postgres-password"}
        DB_DATABASE_NAME=${config.sops.placeholder."docker/immich/postgres-database"}
        DB_USERNAME=${config.sops.placeholder."docker/immich/postgres-user"}
        DB_HOSTNAME=immich-pgvector
        REDIS_HOSTNAME=immich-redis
      '';
      "immich-postgres.env".content = ''
        POSTGRES_PASSWORD=${config.sops.placeholder."docker/immich/postgres-password"}
        POSTGRES_DB=${config.sops.placeholder."docker/immich/postgres-database"}
        POSTGRES_USER=${config.sops.placeholder."docker/immich/postgres-user"}
      '';
    };

    systemd.services.create-immich-network-network = {
      description = "Create immich-network docker network";
      after = [ "docker.service" ];
      before = [
        "docker-immich-redis.service"
        "docker-immich-machine-learning.service"
        "docker-immich-pgvector.service"
      ];
      wantedBy = [
        "docker-immich-redis.service"
        "docker-immich-machine-learning.service"
        "docker-immich-pgvector.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network create immich-network || true'";
      };
    };

    virtualisation.oci-containers.containers = {
      immich = {
        # Port 2283
        image = "ghcr.io/immich-app/immich-server:release";
        volumes = [
          "${dataDirectory}:/usr/src/app/upload"
        ] ++ lib.optionals config.host.containers.immich.enableGPU [
          "/dev/nvidia-caps:/dev/nvidia-caps"
          "/dev/nvidia0:/dev/nvidia0"
          "/dev/nvidiactl:/dev/nvidiactl"
          "/dev/nvidia-modeset:/dev/nvidia-modeset"
          "/dev/nvidia-uvm:/dev/nvidia-uvm"
          "/dev/nvidia-uvm-tools:/dev/nvidia-uvm-tools"
        ];
        environmentFiles = [
          config.sops.templates."immich.env".path
        ];
        ports = [
          "8005:2283"
        ];
        environment = {
          TZ = "Europe/Paris";
          NVIDIA_DRIVER_CAPABILITIES = lib.mkIf config.host.containers.immich.enableGPU "all";
          NVIDIA_VISIBLE_DEVICES = lib.mkIf config.host.containers.immich.enableGPU "all";
        };
        networks = [
          "caddy-bridge"
          "immich-network"
        ];
        extraOptions = lib.mkIf config.host.containers.immich.enableGPU [ "--device=nvidia.com/gpu=all" ];
        dependsOn = [
          "caddy"
          "immich-machine-learning"
          "immich-redis"
          "immich-pgvector"
        ];
      };

      "immich-machine-learning" = {
        image = "ghcr.io/immich-app/immich-machine-learning:release";
        volumes = [
          "${directory}/ml-model-cache:/cache"
        ] ++ lib.optionals config.host.containers.immich.enableGPU [
          "/dev/nvidia-caps:/dev/nvidia-caps"
          "/dev/nvidia0:/dev/nvidia0"
          "/dev/nvidiactl:/dev/nvidiactl"
          "/dev/nvidia-modeset:/dev/nvidia-modeset"
          "/dev/nvidia-uvm:/dev/nvidia-uvm"
          "/dev/nvidia-uvm-tools:/dev/nvidia-uvm-tools"
        ];
        environment = {
          TZ = "Europe/Paris";
          NVIDIA_DRIVER_CAPABILITIES = lib.mkIf config.host.containers.immich.enableGPU "all";
          NVIDIA_VISIBLE_DEVICES = lib.mkIf config.host.containers.immich.enableGPU "all";
        };
        networks = [
          "immich-network"
        ];
        extraOptions = lib.mkIf config.host.containers.immich.enableGPU [ "--device=nvidia.com/gpu=all" ];
      };

      "immich-redis" = {
        image = "redis:6.2-alpine";
        environment = {
          TZ = "Europe/Paris";
        };
        networks = [
          "immich-network"
        ];
        extraOptions = [
          "--health-cmd=redis-cli ping"
        ];
      };

      "immich-pgvector" = {
        image = "tensorchord/pgvecto-rs:pg14-v0.2.0";
        environmentFiles = [
          config.sops.templates."immich-postgres.env".path
        ];
        environment = {
          TZ = "Europe/Paris";
        };
        volumes = [
          "${directory}/pgdata:/var/lib/postgresql/data"
        ];
        networks = [
          "immich-network"
        ];
      };
    };
  };
}